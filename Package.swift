// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BAData",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "BAData",
            targets: ["BAData"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    .package(path: "/Users/Bryan/Developer/Packages/EMUtilities"),
    .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: "5.0.0"),
    .package(url: "https://github.com/realm/realm-cocoa.git", from: "3.19.0"),
    .package(url: "https://github.com/mxcl/PromiseKit", .branch("v7")),
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.0.0"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0-beta.6"),
    .package(url: "https://github.com/kean/Nuke", from: "8.0.1"),
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0"),
    .package(url: "https://github.com/utahiosmac/Marshal", from: "1.2.8")

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "BAData",
            dependencies: ["SwiftyJSON", "RealmSwift", "PromiseKit", "PhoneNumberKit", "Alamofire", "Nuke", "RxSwift", "RxCocoa", "Marshal", "EMUtilities"]),
        .testTarget(
            name: "BADataTests",
            dependencies: ["BAData"]),
    ]
)
