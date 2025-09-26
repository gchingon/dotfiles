help me create a bash script that will strip non alphanumeric characters (non ASCII, emoji, punctuation, illegal filename characters for Mac & Linux) from file or directory names. allow relative or absolute paths, default a depth of 1 with no other options for depth. essentially the output should become 0-9a-z ONLY, delimited with `-` by default with the option of `_` if duplicates are found begin enumeration with `2` and continue

lowercase only
I only want to process the files in the specified directory, eg if I'm in `~/` and I run `dupe_enumerate /Volumes/Samsung/test/*` I want the files and directories in `/Volumes/Samsung/test` to be processed but not any subdirectories in `test/`
I want any non alphanumeric character delimited with - by default, but have the option/argument/flag to choose * eg *-_test-\ -dir\ \ \ -name-___ becomes test-dir-name
the script should rename the files unless the -n|--dry-run flag is chosen
preserve file extensions

process the files as script.sh /path/to/dir or script.sh /path/to/dir/*.ext(ension)
then review the script you create, test it internally against these file names:
 '--test name-',test-name-,'another_ -dupe- ',test---name--,
 '-false- - -name', false-name---,test--name,test-name__, 'another- - -dupe- ',false-name__,'test- name _',false-name---,another-dupe,'falsename-_ -',test-name

rewrite internally as necessary until you do not get any errors THEN share that script
also test the script against a wide variety of challenging filenames, including:

Files with non-ASCII characters: "你好world.txt", "ñáaéeícórgú.pdf"
Files with emojis: "📁document.docx", "report😊.xlsx"
Files that start with special characters: "!@#$test.txt", "...file.jpg"
Files that end with special characters: "data???.csv", "report!!!"
Files with only special characters: "!@#$%^&*", "....."
Mixed cases: "ÜPPERlower123!@#.txt"

please ask clarification questions before writing script.
