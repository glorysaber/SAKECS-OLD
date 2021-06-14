// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SAKECS",
	platforms: [.macOS(.v11),
							.iOS(.v14),
							.tvOS(.v14),
							.watchOS(.v7)
	],
	products: [
		// Products define the executables and libraries produced by a package, and make them visible to other packages.
		.library(
			name: "SAKECS",
			targets: ["SAKECS"])
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		// .package(url: /* package url */, from: "1.0.0"),
		.package(url: "git@github.com:glorysaber/SAKBase.git", .branch("develop"))
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages which this package depends on.
		.target(
			name: "SAKECS",
			dependencies: [.product(name: "SAKBase", package: "SAKBase")]),
		.testTarget(
			name: "SAKECSTests",
			dependencies: ["SAKECS"])
	]
)
