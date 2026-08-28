import ProjectDescription

let project = Project(
    name: "EngineIssue58Repro",
    organizationName: "Engine Issue 58 Reproduction",
    targets: [
        .target(
            name: "EngineIssue58Repro",
            destinations: .macOS,
            product: .app,
            bundleId: "com.example.EngineIssue58Repro",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Engine Issue 58 Repro",
                    "LSMinimumSystemVersion": "13.0",
                ]
            ),
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "Engine"),
            ]
        ),
    ]
)
