#!/usr/bin/env bash
set -e

##
# Environment variables required in App Center Build
# https://docs.microsoft.com/en-us/appcenter/build/custom/variables/
#
# APPCENTER_TOKEN
# https://docs.microsoft.com/en-us/appcenter/api-docs/
#
# DEVICE_SET
# Both the device slug and a defined device set can be used here
#
# APP_OWNER
# It's a combinations of Organization and app name, i.e., {Organization/App-name}
#
# LOCALE
# UTF-8 locale like en_US for english American
##

echo "Found UI tests projects:"
find $APPCENTER_SOURCE_DIRECTORY -regex '*.UITest.*\.csproj' -exec echo {} \;
echo
echo "Building UI test projects:"
find $APPCENTER_SOURCE_DIRECTORY -name '*.UITest.csproj' -exec msbuild {} \;
echo "Compiled projects to run UI tests:"
find $APPCENTER_SOURCE_DIRECTORY -regex '*.bin.*UITest.*\.dll' -exec echo {} \;
if [ -d $APPCENTER_OUTPUT_DIRECTORY]
then
	echo "App Center output directory exists"
else
	echo " App Center output directory does not exists"
	exit 9999
fi

ls $APPCENTER_OUTPUT_DIRECTORY
echo "What is in the source directory"
APPPATH=$APPCENTER_OUTPUT_DIRECTORY/*.ipa
BUILDDIR=$APPCENTER_SOURCE_DIRECTORY/*.UITest/bin/Debug/
UITESTTOOL=$APPCENTER_SOURCE_DIRECTORY/packages/Xamarin.UITest.*/tools
appcenter test run uitest --app $APP_OWNER --devices $DEVICE_SET --test-series "$APPCENTER_BRANCH-$APPCENTER_TRIGGER" --locale $LOCALE --app-path $APPPATH --build-dir $BUILDDIR --async --uitest-tools-dir $UITESTTOOL --token $APPCENTER_TOKEN
