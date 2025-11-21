// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "XiaoHongShuClone",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "XiaoHongShuClone",
            targets: ["XiaoHongShuClone"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.9.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(
            name: "XiaoHongShuClone",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "SnapKit", package: "SnapKit")
            ],
            path: "."
        )
    ]
)