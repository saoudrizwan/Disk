// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Disk",
    platforms: [.iOS(.v9)],
    targets: [
        .target(
            name: "Disk",
            path: "Sources",
            exclude: ["DiskExample"]
        ),
        .testTarget(
            name: "DiskTests",
            dependencies: ["Disk"],
            path: "Tests",
            exclude:  ["DiskExample"]
        )
    ]
)
