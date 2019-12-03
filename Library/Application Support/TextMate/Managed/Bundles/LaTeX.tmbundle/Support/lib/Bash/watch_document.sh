# -- Functions -----------------------------------------------------------------

latex_watch () {
    watch_script="$TM_BUNDLE_SUPPORT"/bin/latex_watch.pl

    file="${TM_LATEX_MASTER:-$TM_FILEPATH}"
    dirname="$(dirname "$file")"
    basename="$(basename "$file" .tex)"
    properties_file="${dirname}/.tm_properties"

    # Check whether file is already being watched
    pid_file="$dirname/.$basename.watcher_pid"
    if [ -f "$pid_file" ]; then
    	if [ 2 -eq $(/bin/ps -p $(cat "$pid_file") | /usr/bin/wc -l) ]
    	then
    		ok=$(CocoaDialog ok-msgbox \
    			--title "LaTeX Watch: File already watched" \
    			--text "Stop watching?" \
    			--informative-text "The file '$file' is already being watched. \
Shall I stop watching it?")
    		if [ "$ok" -eq 1 ]; then
    			kill -KILL $(cat "$pid_file")
    		fi
    		exit
    	fi
    fi

    # Make sure we can find the watch script...
    if [ \! -f "$watch_script" ]; then
    	CocoaDialog msgbox \
    		--button1 Cancel \
    		--title "LaTeX Watch error" \
    		--text "Could not find script" \
    		--informative-text "The file '$watch_script' could not be found. \
Make sure you have installed it in the right place."
    	exit 1
    fi

    # ... and the Perl interpreter
    if [ -x "/usr/bin/perl" ]; then
    	# We prefer /usr/bin/perl, because we want to use Foundation.pm
    	perl="/usr/bin/perl"
    else
    	type perl || {
    		CocoaDialog msgbox \
    			--button1 Cancel \
    			--title "LaTeX Watch error" \
    			--text "Could not find Perl" \
    			--informative-text "I could not locate the perl executable! \
Make sure it's in your PATH ($PATH)."
    		exit 1
    	}
    	perl=perl
    fi

    # Spawn progress bar. Ironically it's quite a CPU hog, so give it a low
    # scheduling priority.
    nice -n 20 CocoaDialog progressbar --indeterminate --title 'LaTeX Watch' \
        --text 'LaTeX Watch: Compiling document' </dev/console &>/dev/null &
    progressbar_pid=$(jobs -p %%)
    disown %%

    watch_script_opts="--textmate-pid $PPID --progressbar-pid $progressbar_pid"
    if [ -n "$TM_LATEX_WATCH_DEBUG" ]; then
        watch_script_opts="$watch_script_opts --debug"
    fi

    # Create a `.tm_properties` file marking this file as master file. This
    # is only done if you set the environment variable
    # `TM_LATEX_WATCH_SET_MASTER` and there exist no `.tm_properties` file in
    # the folder of the file already.
    if [ ! -e "${properties_file}" ] && \
       [ ! -z ${TM_LATEX_WATCH_SET_MASTER+DEFINED} ]; then
        echo "TM_LATEX_MASTER = \"\$CWD/$(basename "${file}")\"" \
             > "${properties_file}"
    fi

    "$perl" "$watch_script" $watch_script_opts "$file" &>/dev/console &
    jobs -p %% > "$pid_file"
}
