basepath=$(cd `dirname $0`; pwd)

# jazzy
jazzy     \
 --objc   \
 --clean  \
 --module-version 2.1.0    \
 --framework-root ./       \
 --module ThinkingSDK      \
 --sdk iphonesimulator     \
 --output "$basepath"/docs \
 --author ThinkingData     \
 --author_url http://http://www.thinkingdata.cn \
 --umbrella-header "$basepath"/../ThinkingSDK/Source/ThinkingAnalyticsSDK.h  \