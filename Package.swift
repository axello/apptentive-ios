// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Apptentive",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "Apptentive",
            targets: ["Apptentive"]
        ),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "Apptentive",
            url: "https://github.com/axello/apptentive-ios/releases/download/5.3.3/Apptentive.xcframework.zip",
            checksum: "3aa2d5dab2d7d9e3be62d810452bef930be5817708de9498fb8140e4046d3db1"
        ),
    ]
)
