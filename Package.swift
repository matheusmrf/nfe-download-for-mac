// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NFeDownloadForMAC",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "NFeDownloadForMacApp",
            targets: ["NFeDownloadForMacApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "NFeDownloadForMacApp",
            path: "Sources/NFeDownloadForMacApp"
        )
    ]
)
