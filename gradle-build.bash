gradle --stop
gradle clean build \
	--refresh-dependencies \
	--build-cache \
	-Dorg.gradle.jvmargs="-Xmx2g" \
	-PmustSkipCacheToRepo=false \
	-PisVerboseCacheToRepo=false
