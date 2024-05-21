// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "JioMeetHealthCareTemplateSDK",
	defaultLocalization: "en",
	platforms: [.iOS(.v12)],
	products: [
		.library(
			name: "JioMeetHealthCareTemplateSDK",
			targets: ["JioMeetHealthCareTemplateSDKTarget"]
		)
	],
	dependencies: [
		.package(
			name: "JioMeetCoreSDK",
			url: "https://github.com/JioMeet/JioMeetCoreSDK_iOS.git",
			.upToNextMajor("4.0.0-alpha.1")
		)
	],
	targets: [
		.binaryTarget(
			name: "JioMeetHealthCareTemplate",
			path: "XCFrameworks/JioMeetHealthCareTemplate.xcframework"
		),
		.target(
			name: "JioMeetHealthCareTemplateSDKTarget",
			dependencies: [
				.target(name: "JioMeetHealthCareTemplate")
			],
			path: "SPMSource",
			exclude: []
		)
	]
)
