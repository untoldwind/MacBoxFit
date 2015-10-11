all: Release
dev: Debug

Release:
	xcodebuild -parallelizeTargets -target BoxFit -configuration Release

Debug:
	xcodebuild -parallelizeTargets -target BoxFit -configuration Debug

clean:
	xcodebuild -parallelizeTargets -alltargets clean
	rm -rf build
	rm -f *~
