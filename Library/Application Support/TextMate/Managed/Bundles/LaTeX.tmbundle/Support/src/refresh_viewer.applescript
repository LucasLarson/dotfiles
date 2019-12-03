#!/usr/bin/osascript

--------------------------------------------------------------------------------
-- Author: René Schwaiger
--
-- Refresh the given PDF in the specified viewer application. The PDF
-- needs to be already open in the viewer application for this to work.
--
-- Usage: refresh_viewer viewer path_to_pdf
--
--		viewer      - The name of the viewer which should be opened
--		path_to_pdf - The path to the PDF file which should be refreshed
--------------------------------------------------------------------------------

on run {viewer, path_to_pdf}
    if viewer is "Skim" then
        tell application "Skim"
            revert (documents whose path is path_to_pdf as text)
        end tell
    else if viewer is "TeXShop" then
        tell application "TeXShop"
            tell documents whose path is path_to_pdf as text to refreshpdf
        end tell
    end if
end run
