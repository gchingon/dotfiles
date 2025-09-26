# ~/.config/zsh/modules/imagemagick.zsh
# ImageMagick functions

imagemagick-resize-50() { magick "$1" -resize 50% "$2"; }
imagemagick-resize-500() { magick "$1" -resize 500 "$2"; }
imagemagick-resize-720() { magick "$1" -resize 720 "$2"; }
imagemagick-shave() { magick "$1" -shave "$3" "$2"; }

# Create text image with color
# Usage: pick-color-fill-text LABEL FONT SIZE FILL OUTPUT [STROKE]
pick-color-fill-text() {
  local label="$1" font="$2" size="$3" fill="$4" file="$5" stroke="$6"
  if [ -n "$stroke" ]; then
    magick -background transparent -density 250 -pointsize "$size" -font "$font" \
      -interline-spacing -15 -fill "$fill" -stroke "$stroke" -strokewidth 2 \
      -gravity center label:"$label" "$file.png"
  else
    magick -background transparent -density 250 -pointsize "$size" -font "$font" \
      -interline-spacing -15 -fill "$fill" -gravity center label:"$label" "$file.png"
  fi
}

# Create YouTube thumbnail
# Usage: youtube-thumbnail LABEL FILENAME
youtube-thumbnail() {
  local label="$1" filename="$2" font="Arial-Black"
  local template="$SCS/images/YT-thumbnail-template.png"
  local output_dir="/Volumes/cold/sucias-pod-files/YT-thumbs"
  local output_file="$output_dir/${filename}-thumb.png"
  magick -background transparent -density 250 -pointsize 27 -font "$font" \
    -interline-spacing -35 -fill gold -stroke magenta -strokewidth 2 \
    -gravity center label:"$label" -rotate -12 "$output_file"
  magick composite -geometry +600+20 "$output_file" "$template" "$output_file"
}