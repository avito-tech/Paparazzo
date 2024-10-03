// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Paparazzo",
    defaultLocalization: "ru_RU",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "PaparazzoCore",
            targets: [
                "PaparazzoCore"
            ]
        ),
        .library(
            name: "Paparazzo",
            targets: [
                "Paparazzo"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/avito-tech/ImageSource.git", from: "4.1.0"),
        .package(url: "ssh://git@stash.msk.avito.ru:7999/ma/avito-ios-navigation.git", from: "1.0.2"),
        .package(url: "ssh://git@stash.msk.avito.ru:7999/iedm/JNWSpringAnimation.git", from: "0.8.0"),
    ],
    targets: [
        .target(
            name: "ObjCExceptionsCatcher",
            publicHeadersPath: "include"
        ),
        .target(
            name: "PaparazzoCore",
            dependencies: [
                "ImageSource",
                "ObjCExceptionsCatcher",
                "JNWSpringAnimation",
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "Paparazzo",
            dependencies: [
                "ImageSource",
                "ObjCExceptionsCatcher",
                "JNWSpringAnimation",
                .product(name: "Marshroute", package: "avito-ios-navigation"),
            ],
            resources: [
                .process("Core/Resources")
            ]
        )
    ]
)
