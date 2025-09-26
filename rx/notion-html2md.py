#!/usr/bin/env python3
"""
ln $HOME/.config/rx/notion-html2md.py -> $HOME/.local/bin/html2md
Notion to Markdown Wiki Converter (collision-safe)

Key features:
-   Deterministic unique slugs for pages (HTML) and CSV row-derived pages (only when a row has a 'large' cell)
-   Two-pass link resolution:
    1) Build page buffers with placeholder links [@PENDING:raw_slug]
    2) Finalize: map raw slugs (from HTML) to final unique slugs, replace placeholders, then write files
-   CSV handling:
    - Render CSVs as markdown pipe tables
    - For any row with a cell > 40 chars, create a separate markdown file named from the first column (collision-safe),
      and replace that cell in the table with a wiki link to the new file
-   Asset handling:
    - Local images copied into ./assets with collision handling
    - Remote http(s) image src kept as external URL (not copied)
"""

import argparse
import logging
import os
import re
import shutil
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from urllib.parse import unquote, urlparse

import pandas as pd
from bs4 import BeautifulSoup, NavigableString


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("notion_converter.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class NotionConverter:
    """Converts Notion exports to markdown wiki format."""

    def __init__(self, source_dir: str, output_dir: str, dry_run: bool = False):
        self.source_dir = Path(source_dir).expanduser()
        self.output_dir = Path(output_dir).expanduser()
        self.assets_dir = self.output_dir / "assets"
        self.dry_run = dry_run

        # Track HTML files to final md filenames
        # original HTML filename (.html) -> final markdown filename (.md)
        self.file_mapping: Dict[str, str] = {}

        # Placeholder links encountered: (source_html, raw_target_slug)
        self.wiki_links: List[Tuple[str, str]] = []

        # Buffers to hold page content until finalize pass
        # final_md_name -> markdown content
        self.page_buffers: Dict[str, str] = {}

        # Slug collision management (scoped)
        # Pages (from HTML) have their own slug space
        self.page_slugs: Dict[str, str] = {}             # slug -> claimed
        self.page_slug_counter: Dict[str, int] = {}      # base slug -> next int

        # CSV row-derived pages use their own slug space (separate from pages)
        self.row_slugs: Dict[str, str] = {}              # slug -> claimed
        self.row_slug_counter: Dict[str, int] = {}       # base slug -> next int

        self.processed_files = 0
        self.total_files = 0

        if not self.dry_run:
            self.output_dir.mkdir(parents=True, exist_ok=True)
            self.assets_dir.mkdir(parents=True, exist_ok=True)

    # ---------------------
    # Naming & IDs
    # ---------------------

    def clean_filename(self, filename: str) -> str:
        """Convert filename (or title) to kebab-case, removing Notion IDs."""
        # Remove Notion ID suffix (32 char hex) and any preceding spaces
        base_name = re.sub(r"\s+[a-f0-9]{32}", "", filename)

        # Remove extension
        name_without_ext = os.path.splitext(base_name)[0]

        # To kebab-case: keep word chars, spaces, dashes, then collapse
        kebab = re.sub(r"[^\w\s-]", "", name_without_ext.lower())
        kebab = re.sub(r"[-\s]+", "-", kebab).strip("-")

        return kebab or "untitled"

    def title_case_display(self, kebab_name: str) -> str:
        """Convert kebab-case to Title Case display name."""
        return kebab_name.replace("-", " ").title()

    def extract_notion_id(self, filename: str) -> Optional[str]:
        """Extract Notion ID (32 hex) from filename."""
        match = re.search(r"([a-f0-9]{32})", filename)
        return match.group(1) if match else None

    def unique_page_slug(self, base_slug: str, notion_id: Optional[str] = None) -> str:
        """Return a unique slug for a page (HTML-derived)."""
        if base_slug not in self.page_slugs and base_slug not in self.page_slug_counter:
            self.page_slugs[base_slug] = "claimed"
            return base_slug

        if notion_id:
            short = notion_id[:8]
            candidate = f"{base_slug}-{short}"
            if candidate not in self.page_slugs:
                self.page_slugs[candidate] = "claimed"
                return candidate

        n = self.page_slug_counter.get(base_slug, 2)
        while True:
            candidate = f"{base_slug}-{n}"
            if candidate not in self.page_slugs:
                self.page_slugs[candidate] = "claimed"
                self.page_slug_counter[base_slug] = n + 1
                return candidate
            n += 1

    def unique_row_slug(self, base_slug: str, parent_page_slug: str) -> str:
        """Return a unique slug for a CSV row-derived page (separate namespace)."""
        # Salt with the parent page slug to stabilize likely duplicates across different pages
        salted = f"{base_slug}-{parent_page_slug}"
        for candidate in (salted, base_slug):
            if candidate not in self.row_slugs and candidate not in self.row_slug_counter:
                self.row_slugs[candidate] = "claimed"
                return candidate

        n = self.row_slug_counter.get(salted, 2)
        while True:
            candidate = f"{salted}-{n}"
            if candidate not in self.row_slugs:
                self.row_slugs[candidate] = "claimed"
                self.row_slug_counter[salted] = n + 1
                return candidate
            n += 1

    # ---------------------
    # CSV handling
    # ---------------------

    def process_csv_file(self, csv_path: Path, parent_page_slug: str, parent_html_name: str) -> str:
        """Convert CSV to markdown table, splitting rows with any cell > 40 chars."""
        try:
            df = pd.read_csv(csv_path)

            # Clean column names (strip whitespace)
            df.columns = df.columns.str.strip()

            if df.empty:
                return "*(No data)*\n"

            # Identify large cells (> 40 chars)
            large_cells = []
            for idx, row in df.iterrows():
                for col, cell in row.items():
                    if pd.notna(cell) and len(str(cell)) > 40:
                        large_cells.append((idx, col, cell))

            # For any row that has a large cell, generate a separate file and replace that cell
            for idx, col, _cell_content in large_cells:
                # First column is expected as identifier; fallback if absent/blank
                identifier_val = df.iloc[idx, 0] if df.shape[1] > 0 else ""
                identifier = str(identifier_val).strip() if pd.notna(identifier_val) else ""
                base_cell_slug = self.clean_filename(identifier) or "row"

                # Unique row slug (independent of pages)
                cell_slug = self.unique_row_slug(base_cell_slug, parent_page_slug)
                cell_md_name = f"{cell_slug}.md"
                cell_md_path = self.output_dir / cell_md_name

                # Build content for the row page: frontmatter + key/value table for the row
                lines: List[str] = []
                lines.append("---")
                lines.append(f"title: {identifier or self.title_case_display(base_cell_slug)}")
                lines.append(f"origin: [[{parent_page_slug}|{self.title_case_display(parent_page_slug)}]]")
                lines.append("---")
                lines.append("")
                lines.append(f"# {identifier or self.title_case_display(base_cell_slug)}")
                lines.append("")
                for col_name, cell_val in df.iloc[idx].items():
                    if col_name != df.columns[0]:  # skip first column as title
                        val = "" if (pd.isna(cell_val)) else str(cell_val)
                        lines.append(f"| {col_name} | {val} |")

                content = "\n".join(lines)

                # Write or buffer the new row page (no placeholders here)
                if self.dry_run:
                    self.page_buffers[cell_md_name] = content
                else:
                    with open(cell_md_path, "w", encoding="utf-8") as f:
                        f.write(content)

                # Replace the large cell with a wiki link to the new file (target is slug w/o .md)
                display_name = self.title_case_display(base_cell_slug)
                df.iloc[idx, df.columns.get_loc(col)] = f"[[{cell_slug}|{display_name}]]"

            # Convert the (possibly modified) DataFrame to a markdown pipe table
            markdown_table = df.to_markdown(index=False, tablefmt="pipe")
            return f"{markdown_table}\n\n"

        except Exception as e:
            logger.error(f"Error processing CSV {csv_path}: {e}")
            return f"*(Error processing table: {e})*\n"

    # ---------------------
    # HTML -> Markdown
    # ---------------------

    def convert_html_to_markdown(self, html_content: str, source_html_name: str) -> str:
        """Convert HTML content to markdown with wiki link placeholders."""
        soup = BeautifulSoup(html_content, "html.parser")

        # Extract title
        title_elem = soup.find("h1", class_="page-title")
        title = title_elem.get_text().strip() if title_elem else os.path.splitext(source_html_name)[0]

        # Build markdown content
        markdown_lines = [f"# {title}\n"]

        # Process main content
        page_body = soup.find("div", class_="page-body")
        if page_body:
            markdown_lines.extend(self.process_element(page_body, source_html_name))

        return "\n".join(markdown_lines)

    def process_element(self, element, source_html_name: str) -> List[str]:
        """Recursively process HTML elements to markdown."""
        lines: List[str] = []

        for child in element.children:
            if isinstance(child, NavigableString):
                text = child.strip()
                if text:
                    lines.append(text)

            elif child.name in ("h1", "h2", "h3"):
                hnum = int(child.name[1])
                prefix = "#" * hnum
                lines.append(f"{prefix} {child.get_text().strip()}")

            elif child.name == "p":
                text = child.get_text().strip()
                if text:
                    lines.append(text)
                    lines.append("")

            elif child.name == "blockquote":
                text = child.get_text().strip()
                if text:
                    lines.append(f"> {text}")
                    lines.append("")

            elif child.name == "a" and "link-to-page" in child.get("class", []):
                # Notion page link -> placeholder for later resolution
                href = child.get("href", "")
                link_text = child.get_text().strip()

                if href.endswith(".html"):
                    linked_file = os.path.basename(href)
                    raw_target_slug = self.clean_filename(linked_file)
                    display_name = self.title_case_display(raw_target_slug)
                    placeholder = f"[[@PENDING:{raw_target_slug}|{display_name}]]"
                    lines.append(placeholder)
                    self.wiki_links.append((source_html_name, raw_target_slug))
                else:
                    lines.append(f"[{link_text}]({href})")

            elif child.name == "figure" and "link-to-page" in child.get("class", []):
                link = child.find("a")
                if link:
                    lines.extend(self.process_element(link, source_html_name))

            elif child.name == "img":
                src = child.get("src", "")
                alt = child.get("alt", "Image")
                if src:
                    asset_markdown = self.handle_image(src, alt, source_html_name)
                    if asset_markdown:
                        lines.append(asset_markdown)

            elif child.name in ["ul", "ol"]:
                # Non-nested list flatten
                list_items = child.find_all("li", recursive=False)
                for item in list_items:
                    prefix = "- " if child.name == "ul" else "1. "
                    item_text = item.get_text().strip()
                    if item_text:
                        lines.append(f"{prefix}{item_text}")
                lines.append("")

            elif child.name in ["details", "summary"]:
                if child.name == "summary":
                    text = child.get_text().strip()
                    if text:
                        lines.append(f"**{text}**")
                else:
                    lines.extend(self.process_element(child, source_html_name))

            elif hasattr(child, "children"):
                lines.extend(self.process_element(child, source_html_name))

        return lines

    # ---------------------
    # Assets
    # ---------------------

    def handle_image(self, src: str, alt: str, source_html_name: str) -> Optional[str]:
        """Return markdown for image; copy local assets; keep remote URLs."""
        try:
            src_decoded = unquote(src)

            # If remote URL, keep external link
            parsed = urlparse(src_decoded)
            if parsed.scheme in ("http", "https"):
                return f"![{alt}]({src_decoded})"

            # Otherwise treat as local relative path to the HTML file
            asset_name = self.copy_asset(src_decoded, source_html_name)
            return f"![{alt}](assets/{asset_name})" if asset_name else None

        except Exception as e:
            logger.error(f"Error handling image {src}: {e}")
            return None

    def copy_asset(self, src_path: str, source_html_name: str) -> Optional[str]:
        """Copy asset file into assets directory and return new filename, or None."""
        try:
            src_path = unquote(src_path)

            # Resolve relative to the source HTML's folder
            if not os.path.isabs(src_path):
                source_dir = os.path.dirname(os.path.join(self.source_dir, source_html_name))
                src_full_path = os.path.join(source_dir, src_path)
            else:
                src_full_path = src_path

            src_file = Path(src_full_path)

            if not src_file.exists():
                logger.warning(f"Asset not found: {src_file}")
                return None

            original_name = src_file.name
            clean_name = self.clean_filename(original_name)
            extension = src_file.suffix
            new_name = f"{clean_name}{extension}"
            dest_path = self.assets_dir / new_name

            # Collision-safe in assets
            if dest_path.exists():
                base = clean_name
                counter = 2
                while True:
                    candidate = self.assets_dir / f"{base}-{counter}{extension}"
                    if not candidate.exists():
                        dest_path = candidate
                        new_name = candidate.name
                        break
                    counter += 1

            if not self.dry_run:
                shutil.copy2(src_file, dest_path)
                logger.info(f"Copied asset: {original_name} -> {new_name}")

            return new_name

        except Exception as e:
            logger.error(f"Error copying asset {src_path}: {e}")
            return None

    # ---------------------
    # Frontmatter
    # ---------------------

    def create_frontmatter(self, title: str, notion_id: Optional[str], parent: Optional[str] = None) -> str:
        """Generate YAML frontmatter for a markdown file."""
        fm = ["---", f"title: {title}"]
        if notion_id:
            fm.append(f"notion_id: {notion_id}")
        if parent:
            fm.append(f"parent: [[{parent}|{self.title_case_display(parent)}]]")
        fm.append("---")
        fm.append("")
        return "\n".join(fm)

    # ---------------------
    # Per-file processing
    # ---------------------

    def process_file(self, html_file: Path) -> None:
        """Process a single HTML file into a buffer; link placeholders resolved later."""
        try:
            with open(html_file, "r", encoding="utf-8") as f:
                html_content = f.read()

            original_name = html_file.name
            base_slug = self.clean_filename(original_name)
            notion_id = self.extract_notion_id(original_name)
            unique_slug = self.unique_page_slug(base_slug, notion_id)

            final_md_name = f"{unique_slug}.md"
            self.file_mapping[original_name] = final_md_name

            # Extract title
            soup = BeautifulSoup(html_content, "html.parser")
            title_elem = soup.find("h1", class_="page-title")
            title = title_elem.get_text().strip() if title_elem else self.title_case_display(base_slug)

            parts: List[str] = []

            # Frontmatter
            frontmatter = self.create_frontmatter(title, notion_id)
            parts.append(frontmatter)

            # Body
            main_content = self.convert_html_to_markdown(html_content, original_name)
            parts.append(main_content)

            # CSV siblings (just tables; row pages only when large cells)
            csv_dir = html_file.parent / html_file.stem
            if csv_dir.exists() and csv_dir.is_dir():
                csv_files = list(csv_dir.glob("*.csv"))
                for csv_file in csv_files:
                    csv_section_title = self.clean_filename(csv_file.name).replace("-", " ").title()
                    parts.append(f"## {csv_section_title}")
                    table_md = self.process_csv_file(csv_file, unique_slug, original_name)
                    parts.append(table_md)

            # Buffer the content for finalize pass
            self.page_buffers[final_md_name] = "\n".join(parts)

            self.processed_files += 1
            logger.info(f"Processed {self.processed_files}/{self.total_files}: {original_name} -> {final_md_name}")

        except Exception as e:
            logger.error(f"Error processing {html_file}: {e}")

    # ---------------------
    # Finalize and Validation
    # ---------------------

    def finalize_links_and_write(self):
        """Resolve [[@PENDING:raw|Display]] placeholders and write files."""
        # raw base slug (from HTML filename) -> final md name
        raw_to_final: Dict[str, str] = {}
        for original_html, final_md in self.file_mapping.items():
            raw = self.clean_filename(original_html)
            if raw not in raw_to_final:
                raw_to_final[raw] = final_md

        fixed_buffers: Dict[str, str] = {}

        placeholder_re = re.compile(r"\[\[@PENDING:([a-z0-9-]+)\|([^\]]+)\]\]")
        for final_md_name, content in self.page_buffers.items():
            def repl(match):
                raw = match.group(1)
                display = match.group(2)
                target_md = raw_to_final.get(raw)
                if not target_md:
                    # Leave it visible if not found
                    return f"[[{raw}|{display}]]"
                target_slug = os.path.splitext(target_md)[0]
                return f"[[{target_slug}|{display}]]"

            fixed = placeholder_re.sub(repl, content)
            fixed_buffers[final_md_name] = fixed

        if not self.dry_run:
            for final_md_name, fixed in fixed_buffers.items():
                out_path = self.output_dir / final_md_name
                with open(out_path, "w", encoding="utf-8") as f:
                    f.write(fixed)

        self.page_buffers = fixed_buffers

    def validate_conversion(self) -> None:
        """Validate the conversion results: check unresolved placeholders."""
        logger.info("Validating conversion...")

        unresolved = []
        for md_name, content in self.page_buffers.items():
            if "[[@PENDING:" in content:
                unresolved.append(md_name)

        if unresolved:
            logger.warning(f"Found unresolved link placeholders in {len(unresolved)} files (first 10):")
            for name in unresolved[:10]:
                logger.warning(f"  {name}")
        else:
            logger.info("All wiki links appear resolved")

    # ---------------------
    # Orchestration
    # ---------------------

    def convert_all(self) -> None:
        """Convert all HTML files in the source directory."""
        html_files = list(self.source_dir.rglob("*.html"))
        self.total_files = len(html_files)

        logger.info(f"Found {self.total_files} HTML files to process")
        logger.info(f"{'DRY RUN: ' if self.dry_run else ''}Converting to {self.output_dir}")

        # First pass: parse/build buffers
        for html_file in html_files:
            self.process_file(html_file)

        # Second pass: resolve placeholders and write
        self.finalize_links_and_write()

        # Validation
        self.validate_conversion()

        logger.info(f"Conversion complete! Processed {self.processed_files} files")
        if self.dry_run:
            logger.info("This was a dry run - no files were actually created")


def main():
    parser = argparse.ArgumentParser(description="Convert Notion exports to markdown wiki (collision-safe)")
    parser.add_argument("source_dir", help="Source directory containing Notion HTML exports")
    parser.add_argument("output_dir", help="Output directory for markdown files")
    parser.add_argument("--dry-run", action="store_true", help="Preview conversion without creating files")
    args = parser.parse_args()

    source_path = Path(args.source_dir).expanduser()
    if not source_path.exists():
        print(f"Error: Source directory does not exist: {source_path}")
        return 1

    converter = NotionConverter(args.source_dir, args.output_dir, args.dry_run)

    try:
        converter.convert_all()
        return 0
    except KeyboardInterrupt:
        logger.info("Conversion interrupted by user")
        return 1
    except Exception as e:
        logger.error(f"Conversion failed: {e}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
