// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Paparazzo",
    platforms: [
            .iOS(.v12)
        ],
    products: [
        .library(
            name: "Paparazzo",
            targets: ["avito-ios-media-picker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/avito-tech/ImageSource.git", from: "4.1.0")
    ],
    targets: [
        .target(
            name: "JNWSpringAnimation",
            path: "JNWSpringAnimation",
            publicHeadersPath: "Headers"
        ),
        .target(
            name: "ObjCExceptionsCatcherHelpers",
            path: "Paparazzo/Core/Helpers/ObjCExceptionsCatcher/Helpers",
            publicHeadersPath: "Headers"
        ),
        .target(
            name: "avito-ios-media-picker",
            dependencies: [
                "ImageSource",
                "JNWSpringAnimation",
                "ObjCExceptionsCatcherHelpers"
            ],
            path: "Paparazzo/Core",
            exclude: ["Helpers/ObjCExceptionsCatcher/Helpers"]
            resources: [
                .copy("Shader/"),
                .copy("Localization/")
            ]
        )
    ]
)
