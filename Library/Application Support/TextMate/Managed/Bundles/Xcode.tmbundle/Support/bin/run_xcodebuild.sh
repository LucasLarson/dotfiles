#!/bin/sh
#
# this command calls xcodebuild giving the name of the project
# directory as the project to build and parses the output for
# file/line information then plays a succes/failure sample
# based on the final outcome
#
# User setting environment variables:
#
#	TM_BUILDSTYLE	build style or configuration name to force; if not set, the build style selected in Xcode will be used
#
# Script API environment variables:
#
# 	XCODE_BUILD_VERB	(optional)	"clean" or "install" or "build"; can be combined as in "clean build" ; unset defaults to "build"
#										note that earlier versions of xcodebuild may not support build verbs
#	XCODE_PROJECT_FILE	(optional)	If you've already found an Xcode project, we don't need/want to find it again.
#

if [[ -n $XCODE_PROJECT_FILE ]]; then
	PROJECT_FILE=$XCODE_PROJECT_FILE
else
	PROJECT_FILE=$(ruby18 -- "${TM_BUNDLE_SUPPORT}/bin/find_xcode_project.rb")
fi

USE_CONFIGURATIONS=$(ruby18 -- "${TM_BUNDLE_SUPPORT}/bin/xcode_version.rb")

#
# Get into the correct directory and make the project file relative to it
#
cd "`dirname "$PROJECT_FILE"`"
PROJECT_FILE=`basename "$PROJECT_FILE"`

#
# Do we have build styles or do we have configurations?
#
STYLEARGNAME="buildstyle"

if [[ $USE_CONFIGURATIONS -eq "0" ]]; then
	BUILD_STYLE="${TM_BUILDSTYLE:-Deployment}"
else	
	BUILD_STYLE="${TM_BUILDSTYLE:-Release}"
	STYLEARGNAME="configuration"
fi

#
# Code to verify the buildconfig uses "xcodebuild --list". But any invocation
# of xcodebuild is expensive. Therefore, only do this extra work if the user
# has a preferred build style.
#
if [[ -n $TM_BUILDSTYLE ]]; then

	# If we have an Xcode project, and it doesn't contain the build style we're looking for,
	# accept the active build style in the project.
	if [[ -d $PROJECT_FILE ]] && xcodebuild -project "$PROJECT_FILE" -list | awk 'display == "yes" { sub(/^[ \t]+/, ""); print }; /Build (styles|Configurations)/ { display = "yes" }' | grep -F "${BUILD_STYLE}" &>/dev/null; then
		BUILD_STYLE="-$STYLEARGNAME $BUILD_STYLE";
	else
		BUILD_STYLE="-active$STYLEARGNAME"
	fi
else
	BUILD_STYLE="-active$STYLEARGNAME"
fi

#
# Force xcodebuild to honour the user's OBJROOT preference as set in Xcode.
# 

OBJROOT=$("${TM_BUNDLE_SUPPORT}"/bin/find_objroot.rb)
echo $OBJROOT

export PROJECT_FILE
xcodebuild ${PROJECT_FILE:+-project "$PROJECT_FILE"} ${TM_TARGET:+-target $TM_TARGET} $BUILD_STYLE $XCODE_BUILD_VERB ${OBJROOT:+"OBJROOT=$OBJROOT"} 2>&1| ruby18 -- "${TM_BUNDLE_SUPPORT}/bin/format_build_output.rb"
