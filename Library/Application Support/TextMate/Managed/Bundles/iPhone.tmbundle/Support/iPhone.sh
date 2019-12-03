IPHONE_SDK_FRAMEWORK_PATH=/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator2.2.sdk/System/Library/Frameworks/
# Cocoa Functions
find "$IPHONE_SDK_FRAMEWORK_PATH"*.framework -name \*.h -exec grep '^[A-Z][A-Z_]* [^;]* \**[A-Z][A-Z][A-Z][A-Za-z]* *(' '{}' \;|perl -pe 's/.*?\s\*?([A-Z][A-Z]\w+)\s*\(.*/$1/'|sort|uniq|./list_to_regexp.rb >/tmp/functions.txt

# Cocoa Protocols Classes
find "$IPHONE_SDK_FRAMEWORK_PATH"*.framework -name \*.h -exec grep '@interface [A-Z][A-Z][A-Za-z]*' '{}' \;|perl -pe 's/.*?interface\s+([A-Z][A-Z][A-Za-z]+).*/$1/'|sort|uniq|./list_to_regexp.rb >/tmp/classes.txt

find "$IPHONE_SDK_FRAMEWORK_PATH"*.framework -name \*.h -exec grep '@protocol [A-Z][A-Z][A-Za-z]*' '{}' \;|perl -pe 's/.*?([A-Z][A-Z][A-Za-z]+).*/$1/'|sort|uniq|./list_to_regexp.rb >/tmp/protocols.txt

# Cocoa Types
find "$IPHONE_SDK_FRAMEWORK_PATH"*.framework -name \*.h -exec grep 'typedef .* _*[A-Z][A-Z][A-Za-z]*' '{}' \;|perl -pe 's/.*?([A-Z][A-Z][A-Za-z]+);.*/$1/'|perl -pe 's/typedef .*? _?([A-Z][A-Z][A-Za-z0-9]+) \{.*/$1/'|grep -v typedef|sort|uniq|./list_to_regexp.rb >/tmp/types.txt

# Cocoa Constants
find "$IPHONE_SDK_FRAMEWORK_PATH"{UIKit,Foundation,CoreGraphics}.framework -name \*.h -exec awk '/\}/ { pr = 0; } { if(pr) print $0; } /^(typedef )?enum .*\{[^}]*$/ { pr = 1; }' '{}' \;|grep '^[[:space:]]*[A-Z][A-Z][A-Z]'|perl -pe 's/^\s*([A-Z][A-Z][A-Z][A-Za-z0-9_]*).*/$1/'|sort|uniq|./list_to_regexp.rb >/tmp/constants.txt

# Cocoa Notifications
find "$IPHONE_SDK_FRAMEWORK_PATH"*.framework -name \*.h -exec grep '\*[A-Z][A-Z].*Notification' '{}' \;|perl -pe 's/.*?([A-Z][A-Z][A-Za-z]+Notification).*/$1/'|sort|uniq|./list_to_regexp.rb >/tmp/notifications.txt