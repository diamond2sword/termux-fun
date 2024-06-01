./gradlew --stop
./gradlew clean build \
	--refresh-dependencies \
	--build-cache \
	-Dorg.gradle.jvmargs="-Xmx2g" \
	--console=rich \
	--warning-mode all \
	-PmustSkipCacheToRepo=false \
	-PisVerboseCacheToRepo=true
