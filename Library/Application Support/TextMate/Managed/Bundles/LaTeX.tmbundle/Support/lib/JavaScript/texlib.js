/* Javascript functions to support texmate.py  */

/*
Use Textmate.system to run the texmate script
The environment variables available to the script are the same as those available to the
original scrip that created the output window.
We can set up a function to capture the output of the script
Then we just need to redisplay the captured html...
*/

// this function will add p elements to the <pre id="preText"> element
// and should give good looking asynchronous output
// The idea for this comes from Javascript the definitive guide p 330 which shows
// a fully featured logging script.
function displayIncrementalOutput(id,className,mess) {
	isAtBottom = false;

	if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight) {
		isAtBottom = true;
	}

	if(mess != null && mess != '')	{
        content = document.getElementById('preText');
        if (typeof this.entry === 'undefined') {
            this.entry = document.createElement("div");
        }
        this.entry.innerHTML += mess
        content.appendChild(this.entry);
	}

	if (isAtBottom)
		gotoEnd();
}

function gotoEnd() {
	window.scrollTo(0,document.body.scrollHeight);
}

function runCommand(theCmd){
	cmd  = 'cd "${TM_PROJECT_DIRECTORY:-$TM_DIRECTORY}"; '
	cmd += '"$TM_BUNDLE_SUPPORT"/bin/texmate.py -addoutput ' + theCmd;
	TextMate.isBusy = true;
	myCommand = TextMate.system(cmd, function(task) { TextMate.isBusy = false; } );
	myCommand.onreadoutput = latexReadOutput;
	myCommand.onreaderror = latexReadError;
};

function runLatex(){
    runCommand('latex')
};

function runBibtex(){
    runCommand('bibtex')
};

function runClean(){
    runCommand('clean')
};

function runMakeIndex(){
    runCommand('index')
};

function runView(){
    runCommand('view')
};

function runConfig(){
    cmd = '"$TM_BUNDLE_SUPPORT"/bin/configure.py'
    myCommand = TextMate.system(cmd, function(task) { TextMate.isBusy = false; } );

}
function latexReadOutput(str){
	displayIncrementalOutput('info', 'info', str);
};

function latexReadError(str){
	displayIncrementalOutput('error', 'error', str);
};

function getElementsByClassName(strTagName, strClassName){
        var arrElements = document.getElementsByTagName(strTagName);
	    var arrReturnElements = new Array();
	    strClassName = strClassName.replace(/\-/g, "\\-");
	    var oRegExp = new RegExp("(^|\\s)" + strClassName + "(\\s|$)");
	    var oElement;
	    for(var i=0; i<arrElements.length; i++){
	        oElement = arrElements[i];
	        if(oRegExp.test(oElement.className)){
	            arrReturnElements.push(oElement);
	        }
	    }
	    return (arrReturnElements);
	}

function makeFmtWarnVisible() {
    var warnElements = getElementsByClassName("*","fmtWarning");
    var oElement;
    for(var i=0;i<warnElements.length;i++) {
        warnElements[i].style.display = (warnElements[i].style.display == "none" || warnElements[i].style.display == "" ? "block" : "none");
    }
}

function makeLatexmkVisible() {
    var warnElements = getElementsByClassName("*","ltxmk");
    var oElement;
    for(var i=0;i<warnElements.length;i++) {
        warnElements[i].style.display = (warnElements[i].style.display == "none" || warnElements[i].style.display == "" ? "block" : "none");
    }
}
