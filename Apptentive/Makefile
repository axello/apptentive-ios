#!/bin/sh
#
# Builder makefile for Apptentive
#
# Axel Roest, 2021
#

# iOS devices

PROJECT = "Apptentive"

all : zip

# iOS simulators
ios : Apptentive.xcodeproj
	xcodebuild archive \
		-scheme Apptentive \
		-archivePath "archives/$(PROJECT)-iOS.xcarchive" \
		-destination "generic/platform=iOS" \
		-sdk iphoneos \
		SKIP_INSTALL=NO \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# "archives/$(PROJECT)-iOS-simulator.xcarchive"
simulator : Apptentive.xcodeproj
	xcodebuild archive \
		-scheme Apptentive \
		-archivePath "archives/$(PROJECT)-iOS-simulator.xcarchive" \
		-destination "generic/platform=iOS Simulator" \
		-sdk iphonesimulator \
		SKIP_INSTALL=NO \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# create the XCFramework itself.
framework : ios simulator
	rm -r "$(PROJECT).xcframework"
	xcodebuild -create-xcframework \
		-framework "archives/$(PROJECT)-iOS.xcarchive/Products/Library/Frameworks/$(PROJECT).framework" \
		-framework "archives/$(PROJECT)-iOS-simulator.xcarchive/Products/Library/Frameworks/$(PROJECT).framework" \
		-output "$(PROJECT).xcframework"

zip : framework
	zip -r -X ../$(PROJECT).xcframework.zip $(PROJECT).xcframework
	swift package compute-checksum ../$(PROJECT).xcframework.zip
	
