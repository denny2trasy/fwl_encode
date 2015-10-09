all:
	xcodebuild -scheme fwl_encoder build

list:
	xcodebuild -list -project fw_encoder.xcodeproj

app:

	xcodebuild -scheme fwl_encoder archive \
	    -archivePath release/fwl_encoder.xcarchive

	xcodebuild -exportArchive -exportFormat app \
		-archivePath "release/fwl_encoder.xcarchive" \
		-exportPath "release/fwl_encoder.app"
#		-exportProvisioningProfile "MyCompany Distribution Profile"
