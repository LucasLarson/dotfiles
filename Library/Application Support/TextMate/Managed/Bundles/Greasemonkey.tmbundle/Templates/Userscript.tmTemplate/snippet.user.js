// ==UserScript==
// @name          ${1:Name}
// @namespace     ${2:${TM_NAMESPACE:http://CHANGE-THIS-TO-SOMETHING-UNIQUE}}
// @description   ${3:Description.}
// @include       ${4:`
	# I think all this must be inline, as TM_ENVs aren't maintained when this is applied by an AppleScript
	# Get currently open page in Firefox, if there is one
	if $(ps auxww | grep -q [f]irefox); then
		CURRENT_URL=$(osascript <<APPLESCRIPT
			try
				tell window 1 of application "Firefox" to return its $(printf '\307class curl\310')
			end try
		APPLESCRIPT)
	fi
	[[ -n "$CURRENT_URL" ]] && ruby18 -e "exit 1 unless %{$CURRENT_URL}=~ /^(https?|ftp):/" && echo "$CURRENT_URL" || echo "*"
`}
// ==/UserScript==

$0