# Template

Select `File > New From Template > Greasemonkey > Userscript` to create a new script from template. The template outputs this:

	// ==UserScript==
	// @name          Name
	// @namespace     http://www.example.com
	// @description   Description.
	// @include       *
	// ==/UserScript==


	
	/* Your favorite functions go here. */

The metadata block is a snippet, with placeholders. If you set a `TM_NAMESPACE` shell variable in the TextMate preferences (`Preferences > Advanced > Shell Variables`), this will be used as the default `@namespace`. If you have a page currently open in Firefox, that will be the default value for the `@include`.

You should change the `template.user.js` template to include whatever functions you commonly use. The snippet can be modified in the bundle editor (`File > New From Template > Edit Templates…`) as `snippet.user.js`.

Optionally, if you create a file `~/Library/Preferences/com.macromates.textmate.gmbundle.staples.user.js`, the `/* Your favorite functions go here. */` comment will be substituted with its contents whenever a new script is created. This might be useful if you want to version control your staple code.

If you often create new userscripts, you may wish to add (in the Bundle Editor) a key equivalent such as &#x2303;&#x2325;&#x21E7;&#x2318;G for this template.



# Snippets


## @include and @exclude (i&#x21E5; and e&#x21E5;)

Within the header block, the snippets `i` and `e` add `@include` and `@exclude` directives with `http://` as a preselected value. The next tab stop puts the caret after `http://`.

Sadly, TextMate doesn't support snippets-within-snippets yet, so this does not work until after you've broken out of the `header` snippet. However, [Continue Header URL](#continue_header_url) works fine in snippets.


## Continue Header URL (&#x2305;) <span id="continue_header_url"></span>

Available when writing `@include` and `@exclude` directives. Hitting &#x2305; adds another of the same directive on the next line and moves the caret.

If you want to add another directive with a similar URL, consider using `Bundles > Text > Duplicate Line` (&#x2303;&#x21E7;D) instead.

Strictly speaking a command, but it fits with the snippets.


## GM_log (log&#x21E5;)

`log` inserts `GM_log("info")` with `"info"` pre-selected. The next tab stop selects just `ìnfo`. Start typing directly to log a variable, or tab once and then type, to input a string.

## console.log (clog&#x21E5;)

Inserts `console.log("Debug: %o", object)` (see [Firebug console documentation](http://www.getfirebug.com/console.html)) with the string contents pre-selected. The next tab stop selects the object.


## GM&#95;setValue and GM&#95;getValue (set&#x21E5; and get&#x21E5;)

Inserts those function calls. The contents of the key string are pre-selected. The next two tab stops select `"value"` and `value` in that order. Start typing at the first tab stop to specify a variable, and the second to specify a string.


## GM&#95;addStyle (css&#x21E5;)

Expands to `GM_addStyle("CSS");` with the string contents pre-selected.


## GM&#95;xmlhttpRequest (xhr&#x21E5;)

Inserts that function call, with a `GET` method (`POST` is messy).

Tab stops are in turn the url value, the url value string contents, the entire onload value and the body of a pre-defined onload callback function.


## GM&#95;registerMenuCommand (menu&#x21E5;)

Inserts that function call, with tab stops selecting in turn the command name string contents, the entire callback function and the body of a pre-defined function.


## GM&#95;openInTab (tab&#x21E5;)

Inserts that function call, with tab stops selecting in turn the entire URL string and the string contents.


# Commands


## Open Installed Script&hellip; (&#x2303;&#x2325;&#x2318;G)

Displays a dialog listing every installed userscript, with the choice of alphabetical or chronological (most recently installed first) ordering. Select a script and confirm to open it.

There is also a checkbox to only list scripts in your namespace. Your namespace is the value of the `TM_NAMESPACE` shell variable in the TextMate preferences (`Preferences > Advanced > Shell Variables`). The checkbox will limit the listed scripts to those where the `@namespace` value *contains* your namespace. This means it will list scripts with a namespace like `http://yournamespace.tld+http://othernamespace.tld` (for collaborations or derivations) as well. No scripts will be listed if your namespace is empty or unset.

You may wish to remove (in the Bundle Editor) the `source.js.greasemonkey` scope for this command so that it's globally available in TextMate.


## Install and Edit (&#x2318;B)

If you write a new script and hit &#x2318;B, the script will be installed, the old file closed and the installed version opened for editing. This makes starting new scripts vastly less annoying.

**Caveat:** "Enable access for assistive devices" must be toggled on in the Universal Access prefpane, otherwise closing the old file will not work.

When the old file is closed, any unsaved changes are discarded.

Like the extension, this command will overwrite an old script if its name and namespace are both identical to that of the script being installed.


## Update Metadata (&#x2318;D)

Hit &#x2318;D (conveniently next to the S of saving fame) to update the `config.xml` metadata from the values in the script file.

Greasemonkey writes the `@name`, `@include`, `@exclude` values and friends to `config.xml` when a script is installed. After that time, these values are not updated as the script file changes but must be changed in the "Manage User Scripts" window &ndash; or with this command.

**Caveats:** The command replaces the metadata values with the script values. This means that if you've e.g. changed `@include`s in "Manage User Scripts" but not in the script itself, your modifications are lost.

Greasemonkey uses the `@name` and `@namespace` to uniquely identify a script. If you change these values in `config.xml`, it will be considered a different script than before &ndash; so if you later install a script with the old name, that script will not replace the one you have.

Also, it will not recognize any values defined with `GM_set()` using another script name.


## Uninstall Script

Uninstalls the currently open script and moves it to Trash, then closes the buffer. Prompts for confirmation first.

No keyboard shortcut by default.

**Caveat:** Doesn't remove any data set by the script using `GM_setValue`.


## Upload to Userscripts.org (&#x2318;U)

Sends the currently open script to [Userscripts.org](http://userscripts.org), as a new contribution or as an update.

You will be prompted for your log-in details the first time you run this command. After that, you are prompted only if a log-in fails.

If the name of the script matches the name of a single remote script, an update will be performed automatically. If there are no remote scripts, the script will automatically be posted as new. In all other cases &ndash; if there is no remote script with this name, or multiple remote scripts with this name &ndash; you will be prompted whether to add as new or update, with the most probable option pre-selected.

The list of remote scripts to update is sorted by increasing [minimum edit distance](http://en.wikipedia.org/wiki/Damerau-Levenshtein_distance) &ndash; how similar the name is to that of the currently open script.

**Caveats:** Your username and password are stored in plain text as `~/Library/Preferences/com.macromates.textmate.gmbundle.plist`, which is not the best of security.

There is currently no interface to reset or change valid log-in details. If you want to do those things, delete or modify the preference file manually, or trigger a failed log-in by temporarily changing your Userscripts.org password.


## Reload Firefox (&#x2318;R) <span id="reload_firefox"></span>

Hit &#x2318;R to activate Firefox and reload the current page, typically after making changes to a script. The file is saved automatically before reloading.

**Caveats:** Either "Enable access for assistive devices" must be on, *or* Firefox should not be configured to open URLs from external applications in new tabs. If neither is true, the command will not be able to reload Firefox.


## Reload Firefox and Return (&#x21E7;&#x2318;R)

Activates Firefox and reloads the current page, then returns focus to TextMate after 5 seconds. Useful to check the result of script changes that aren't about lengthy interaction.

Modify the command with the bundle editor (`Bundles > Bundle Editor > Edit Commands…`) to change the delay.

**Caveats:** Same as for [Reload Firefox](#reload_firefox).


## Manage GM_Values

Opens `about:config` in Firefox and filters by the script being edited, exposing any `GM_setValue()` values to view and edit.

**Caveats:** "Enable access for assistive devices" must be toggled on in the Universal Access prefpane, otherwise filtering will not work.

Does not handle all weird characters properly.

Works by outputting keystrokes into the about:config filter bar. If you change the focus from the filter bar, the keystrokes will go there instead.


## Toggle Logs in Document / Selection

In the selection or else the entire document, all `GM_log`, `console.log` and `unsafeWindow.console.log` function calls are commented out if any weren't; otherwise all such function calls are uncommented.


## Remove Logs in Document / Selection

Removes all `GM_log`, `console.log` and `unsafeWindow.console.log` function calls in the selection or else the entire document.


## Documentation for Word / Selection (&#x2303;H) <span id="documentation_for_word_selection"></span>

Opens a web window with documentation for the currently focused or selected word.

This is an extended version of the command from the JavaScript bundle, but with support for Greasemonkey constructs.  


## Resources (&#x2303;&#x21E7;H)

Invoking &#x2303;&#x21E7;H opens a menu where you can choose a help resource by clicking or pressing the listed number.

The resources are 

1. [Gecko DOM Element](http://developer.mozilla.org/en/docs/DOM:element#Properties)
2. [XPath](http://www.w3schools.com/xpath/)
3. [GreaseSpot Wiki](http://wiki.greasespot.net/Main_Page)
4. [Forum: US.O Script Development](http://userscripts.org/forums/1)
5. [IRC: #javascript@Freenode](irc://irc.freenode.net/javascript)

The Userscripts.org forum opens in your default browser, and the IRC link in your IRC client, if you have one. The other pages open in a web window.

Do customize this to whatever resources you commonly use, by editing, removing or duplicating commands as appropriate.


## Help

This document in a web window.



# Grammar/Highlighting Tips

These are some ways you can [modify your theme](http://macromates.com/textmate/manual/themes) to get nicer syntax highlighting of userscripts.

* Add a style for `meta.header.greasemonkey`, perhaps a background color, to change the appearance of metadata headers.
* Add a style for `meta.directive.nonstandard.greasemonkey keyword` to have non-standard metadata keywords (e.g. `@version`) highlighted differently from standard keywords (e.g. `@name`).



# Credits

[Originally](http://adamv.com/dev/textmate/greasemonkey) by Adam Vandenberg, who wrote most of the grammar and a few snippets.

The [Documentation for Word / Selection](#documentation_for_word_selection) command is originally by [Thomas Aylott](http://subtlegradient.com/), I think.

Improved by and currently maintained by [Henrik Nyh](http://henrik.nyh.se/) who added a bit of everything. 

Any part of the bundle is free to modify and redistribute with due credit unless otherwise noted.
