// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "swift-fun",
  platforms: [
    .iOS(.v18),
    .macOS(.v15),
    .tvOS(.v18),
    .macCatalyst(.v18),
    .watchOS(.v11),
    .visionOS(.v2),
  ],
  products: [],
  targets: []
)

@MainActor
func addProduct(
  _ name: String,
  dependencies: [Target.Dependency] = []
) {
  package.products.append(.library(name: name, targets: [name]))
  package.targets.append(
    contentsOf: [
      .target(name: name, dependencies: dependencies),
      .testTarget(name: name + "Tests", dependencies: [.byName(name: name)])
    ]
  )
}

addProduct("Either")
addProduct("SequenceBuilder", dependencies: ["Either"])
addProduct("StdPlus")

for target in package.targets {
  var swiftSettings = target.swiftSettings ?? []
  swiftSettings.append(contentsOf: [
    .defaultIsolation(nil),
    .strictMemorySafety(),
    .swiftLanguageMode(.v6),
  ])
  target.swiftSettings = swiftSettings
}
