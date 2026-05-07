// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ThunderCloud",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ThunderCloud",
            targets: ["ThunderCloud"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/3sidedcube/ThunderBasics.git",
            branch: "claude/migrate-carthage-to-spm-a5G5S"
        ),
        .package(
            url: "https://github.com/3sidedcube/ThunderRequest.git",
            branch: "claude/migrate-carthage-to-spm-a5G5S"
        ),
        .package(
            url: "https://github.com/3sidedcube/ThunderTable.git",
            branch: "claude/migrate-carthage-to-spm-a5G5S"
        ),
        .package(
            url: "https://github.com/3sidedcube/ThunderCollection.git",
            branch: "claude/migrate-carthage-to-spm-a5G5S"
        ),
        .package(
            url: "https://github.com/3sidedcube/Baymax.git",
            branch: "claude/migrate-carthage-to-spm-a5G5S"
        )
    ],
    targets: [
        .target(
            name: "ThunderCloudObjC",
            path: "Sources/ThunderCloudObjC",
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedFramework("SystemConfiguration"),
                .linkedLibrary("z")
            ]
        ),
        .target(
            name: "ThunderCloud",
            dependencies: [
                "ThunderCloudObjC",
                "ThunderBasics",
                "ThunderRequest",
                "ThunderTable",
                "ThunderCollection",
                "Baymax"
            ],
            path: "Sources/ThunderCloud",
            resources: [
                .process("AccordionTabBarItemTableViewCell.xib"),
                .process("AnimatedImageListCell.xib"),
                .process("AnimationListItemCell.xib"),
                .process("CollectionItemViewCell.xib"),
                .process("EditLocalisationTableViewCell.xib"),
                .process("EmbeddedLinksInputCheckItemCell.xib"),
                .process("HeaderListItemCell.xib"),
                .process("ImageSelectionCollectionViewCell.xib"),
                .process("LegacySpotlightImageCollectionViewCell.xib"),
                .process("LegacySpotlightListItemCell.xib"),
                .process("LogoListItemCell.xib"),
                .process("NumberedViewCell.xib"),
                .process("PokemonTableViewCell.xib"),
                .process("ProgressListItemCell.xib"),
                .process("SingleSelectionTableViewCell.xib"),
                .process("SpotlightCollectionViewCell.xib"),
                .process("SpotlightListItemCell.xib"),
                .process("StandardGridItemCell.xib"),
                .process("StormTableViewCell.xib"),
                .process("ToggleableListItemCell.xib"),
                .process("UnorderedListItemCell.xib"),
                .process("VideoListItemViewCell.xib"),
                .process("DeveloperMode.storyboard"),
                .process("Login.storyboard"),
                .process("Quiz.storyboard"),
                .process("StormAssets.xcassets"),
                .copy("Settings.bundle")
            ]
        ),
        .testTarget(
            name: "ThunderCloudTests",
            dependencies: ["ThunderCloud"],
            path: "Tests/ThunderCloudTests",
            resources: [
                .copy("test.tar.gz"),
                .copy("test_ungzipped_base64.txt")
            ]
        )
    ]
)
