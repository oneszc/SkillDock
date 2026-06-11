// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SkillDock",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "SkillDockCore", targets: ["SkillDockCore"]),
        .executable(name: "SkillDockApp", targets: ["SkillDockApp"])
    ],
    targets: [
        .target(name: "SkillDockCore"),
        .executableTarget(
            name: "SkillDockApp",
            dependencies: ["SkillDockCore"],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "SkillDockCoreTests", dependencies: ["SkillDockCore"]),
        .testTarget(name: "SkillDockAppTests", dependencies: ["SkillDockApp", "SkillDockCore"])
    ]
)
