# About

This is the official repository for [TextMate](http://github.com/textmate/textmate)'s LaTeX bundle. For a description of some of the features provided by this bundle, please take a look at the [help document](Support/help/Help.pdf).

# Installation

You can install this bundle in TextMate by opening the preferences and going to the bundles tab. After installation it will be automatically updated for you. Please keep in mind that it sometimes takes a little while before [Michael](http://github.com/infininight) or [Allan](http://github.com/sorbits) have time to deploy the changes made to this bundle.

If there are some changes that you want to test immediately, then please follow these instructions:

1. Uninstall the LaTeX bundle inside TextMate's preferences
2. Open Terminal
3. Go to the bundle folder:

    ```sh
    cd ~/Library/Application\ Support/TextMate/Managed/Bundles
    ```

4. Clone the repository:

    ```sh
    git clone https://github.com/textmate/latex.tmbundle.git
    ```

5. Restart TextMate (<kbd>^</kbd> + <kbd>⌘</kbd> + <kbd>Q</kbd>) to make sure it registered the changes

# Feedback

Before you report an issue please read the [ FAQ](http://github.com/textmate/latex.tmbundle/wiki/FAQ). You can report bugs or feature request via the [issue tracker](https://github.com/textmate/latex.tmbundle/issues). If you have a more general problem, then please use the [mailing list](http://lists.macromates.com/listinfo/textmate).

# Contribute

There are many ways in which you can contribute to the bundle:

* Spread the word
* Report bugs or tell us what features you want to see next
* Show your appreciation by starring this repository
* Improve the bundle by committing your own code

Before you contribute any code, please read both the [bundle styleguide](http://kb.textmate.org/bundle_styleguide) and the [commit styleguide](http://kb.textmate.org/commit_styleguide). Please also make sure, that your changes do not break any of the [bundle tests](Makefile).

# License

If not otherwise specified (see below), files in this repository fall under the following license:

	Permission to copy, use, modify, sell and distribute this
	software is granted. This software is provided "as is" without
	express or implied warranty, and with no claim as to its
	suitability for any purpose.

An exception is made for files in readable text which contain their own license information, or files where an accompanying file exists (in the same directory) with a “-license” suffix added to the base-name name of the original file, and an extension of txt, html, or similar. For example “tidy” is accompanied by “tidy-license.txt”.
