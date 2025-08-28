# VHS documentation
#
# Output:
#   Output <path>.gif               Create a GIF output at the given <path>
#   Output <path>.mp4               Create an MP4 output at the given <path>
#   Output <path>.webm              Create a WebM output at the given <path>
#
# Require:
#   Require <string>                Ensure a program is on the $PATH to proceed
#
# Settings:
#   Set FontSize <number>           Set the font size of the terminal
#   Set FontFamily <string>         Set the font family of the terminal
#   Set Height <number>             Set the height of the terminal
#   Set Width <number>              Set the width of the terminal
#   Set LetterSpacing <float>       Set the letter spacing of the terminal
#   Set LineHeight <float>          Set the line height of the terminal
#   Set LoopOffset <float>%         Set the starting frame offset for the GIF loop
#   Set Theme <json|string>         Set the theme of the terminal
#   Set Padding <number>            Set the padding of the terminal
#   Set Framerate <number>          Set the framerate of the recording
#   Set PlaybackSpeed <float>       Set the playback speed of the recording
#   Set MarginFill <hex-color>      Set the color of the margin
#   Set Margin <number>             Set the size of the margin
#   Set BorderRadius <number>       Set terminal border radius, in pixels
#   Set WindowBar <string>          Set window bar type (one of: Rings, RingsRight, Colorful, ColorfulRight)
#   Set WindowBarSize <number>      Set window bar size, in pixels (Default: 40)
#   Set TypingSpeed <time>          Set the typing speed of the terminal. Default is 50ms
#
# Sleep:
#   Sleep <time>                    Sleep for a set amount of <time> in seconds
#
# Type:
#   Type[@<time>] "<characters>"    Type <characters> into the terminal with a
#                                   <time> delay between each character
#
# Keys:
#   Backspace[@<time>] [number]     Press the Backspace key
#   Down[@<time>] [number]          Press the Down key
#   Enter[@<time>] [number]         Press the Enter key
#   Space[@<time>] [number]         Press the Space key
#   Tab[@<time>] [number]           Press the Tab key
#   Left[@<time>] [number]          Press the Left Arrow key
#   Right[@<time>] [number]         Press the Right Arrow key
#   Up[@<time>] [number]            Press the Up Arrow key
#   Down[@<time>] [number]          Press the Down Arrow key
#   PageUp[@<time>] [number]        Press the Page Up key
#   PageDown[@<time>] [number]      Press the Page Down key
#   Ctrl+<key>                      Press the Control key + <key> (e.g. Ctrl+C)
#
# Display:
#   Hide                            Hide the subsequent commands from the output
#   Show                            Show the subsequent commands in the output

Output assets/demo.gif
Require emojify

Set FontSize 16
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 100ms
Set WindowBar Colorful

Type "# Emojify-Go Demo - Lightning Fast Emoji Conversion"
Sleep 1s
Enter
Enter
Sleep 1s

Type "# Show version"
Sleep 500ms
Enter
Type "emojify --version"
Sleep 500ms
Enter
Enter
Sleep 3s

Type "# Convert emoji aliases to Unicode"
Sleep 500ms
Enter
Type 'echo "Hello :wave: world :rocket:" | emojify'
Sleep 500ms
Enter
Enter
Sleep 3s

Type "# Works great with git logs"
Sleep 500ms
Enter
Type 'echo "feat: add new feature :sparkles:" | emojify'
Sleep 500ms
Enter
Enter
Sleep 3s

Type "# Decode emojis back to aliases"
Sleep 500ms
Enter
Type 'echo "Deploy completed 🚀 💯" | emojify --decode'
Sleep 500ms
Enter
Enter
Sleep 3s

Type "# Pipeline friendly - process files"
Sleep 500ms
Enter
Type 'echo -e ":fire: Performance\n:bug: Bug fix\n:books: Documentation" | emojify'
Sleep 500ms
Enter
Enter
Sleep 3s

Type "# Lightning fast! 169.9x faster than bash version"
Sleep 500ms
Enter
Sleep 3s
