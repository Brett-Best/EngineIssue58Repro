// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EngineIssue58Repro",
    dependencies: [
        .package(
            url: "https://github.com/nathantannar4/Engine",
            exact: "2.15.1"
        ),
    ]
)
