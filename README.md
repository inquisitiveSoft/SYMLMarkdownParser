# Why another Markdown Parser?
I wanted a parser where the semantics are abstracted from the styling. It's relitively efficient and thread safe. Designed for *as you type* syntax highlighting. iOS and Mac compatible.

![Screenshot of the Example App](https://raw.githubusercontent.com/inquisitiveSoft/SYMLMarkdownParser/master/Screenshot.png)

Get in touch if you have any comments of queries: [@inquisitivesoft](https://twitter.com/inquisitiveSoft). I'm open to issues or pull requests and would love to hear if you end up using SYMLMarkdownParser in one of your projects.

# Where to Start
- The core processing is all done in SYMLMarkdownParser.h's `SYMLParseMarkdown()` function
- SYMLMarkdownTextFormatter's `-parseString:…` method is a good place to look for example usage

# What it doesn't do
- It doesn't convert markdown to HTML. There are many more feature complete parsers for that: [MultiMarkdown-4](https://github.com/fletcher/MultiMarkdown-4) is my current favourite.
- Currently doesn't highlight `code` or inline em*phas*is elements
- Doesn't have namespace-prefixes
- Needs tests

# Requirements
- Requires [RegexKitLite](http://regexkit.sourceforge.net/) which links against the system *libicucore.dylib* library
- Tested on iOS 7 and OS X 10.9, but should be compatible back to iOS 4.0 and OS X 10.6

# License
Released under the MIT license: [http://opensource.org/licenses/mit-license.php](http://opensource.org/licenses/mit-license.php)