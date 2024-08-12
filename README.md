# Color Counter

Color Counter is an Aseprite plugin that outputs how many times each RGB color is used in the active sprite.

## Installation Steps

- Must have [Aseprite](https://www.aseprite.org/) downloaded

1. Download `Color Counter.aseprite-extension`
1. Double-click or execute the file
1. Click through prompts to install the extension

## How to Use

1. Open a sprite in Aseprite and go to Sprite > Count Colors to run the script
1. Add a shortcut by going to Edit > Keyboard Shortcuts > search for Count Colors > hover over `Key` column and click on `Add` button > fill in details > click `OK`

## Limitations

- Avoid use on more complex art outside of pixel art because Aseprite will freeze due to performance issues
- Sprite must be in RGB mode

## Setup Development Environment (Windows)

1. Download [VSCode](https://code.visualstudio.com/download)
1. Add Lua (by sumneko) and markdownlint extensions to VSCode
1. Clone repo from [Github](https://github.com/bjyoung/Color-Counter)

## Generating the Extension

1. Make sure you have Aseprite installed
1. Go to the root project folder
1. Right-click on the Color Counter folder > `Compress to ZIP file`. If you don't have that option, use any compression method to ZIP the folder.
1. Rename the ZIP file extension to `.aseprite-extension`
1. Double-click the `.aseprite-extension` file to install the extension.

## Links

- [Source code](https://github.com/bjyoung/Color-Counter)

## License

Color Counter

Copyright (c) 2024 Brandon Young

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
