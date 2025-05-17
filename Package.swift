// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Compass4Success",
    platforms: [
        .iOS(.v16),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Compass4Success",
            targets: ["Compass4Success"]),
    ],
    dependencies: [
        // Networking and Authentication
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
        .package(url: "https://github.com/auth0/JWTDecode.swift.git", from: "3.1.0"),
        
        // UI Components
        .package(url: "https://github.com/siteline/swiftui-introspect.git", from: "1.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.1"),
        
        // Utilities
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.0.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.45.0"),
        
        // Charts and Visualization
        .package(url: "https://github.com/danielgindi/Charts.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "Compass4Success",
            dependencies: [
                "Alamofire",
                .product(name: "JWTDecode", package: "JWTDecode.swift"),
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
                "Kingfisher",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "DGCharts", package: "Charts")
            ],
            path: "Compass4Success"
        ),
        .testTarget(
            name: "Compass4SuccessTests",
            dependencies: ["Compass4Success"],
            path: "Tests/Compass4SuccessTests"
        )
    ]
) 