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
            name: "Paparazzo",
            targets: ["PaparazzoCore"]),
        .library(
            name: "PaparazzoMarshroute",
            targets: ["PaparazzoMarshroute"]),
    ],
    dependencies: [
        .package(url: "https://github.com/avito-tech/ImageSource.git", from: "4.1.0"),
        .package(url: "ssh://git@stash.msk.avito.ru:7999/ma/avito-ios-navigation.git", from: "1.0.2"),
    ],
    targets: [
        .target(
            name: "JNWSpringAnimation"
        ),
        .target(
            name: "ObjCExceptionCatcherHelper"
        ),
        .target(
            name: "PaparazzoCore",
            dependencies: [
                "ImageSource",
                "JNWSpringAnimation",
                "ObjCExceptionCatcherHelper"
            ],
            resources: [
                .copy("Resources/CameraShader.metallib"),
            ]
        ),
        .target(
            name: "PaparazzoMarshroute",
            dependencies: [
                "ImageSource",
                "JNWSpringAnimation",
                "ObjCExceptionCatcherHelper",
                .product(name: "Marshroute", package: "avito-ios-navigation"),
            ],
            resources: [
                .copy("PaparazzoCore/Resources/CameraShader.metallib"),
            ]
        ),
    ]
)
