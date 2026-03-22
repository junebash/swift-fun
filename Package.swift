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
.addProduct("Either")
.addProduct("SequenceBuilder", dependencies: ["Either"])
.addProduct("StdPlus")
.addProduct("Box")
.addProduct("AsyncPlus")
.addSwiftSettingsToAllTargets([
  .swiftLanguageMode(.v6),
])

// MARK: - Helpers

extension Package {
  @discardableResult
  func addProduct(
    _ name: String,
    dependencies: [Target.Dependency] = []
  ) -> Self {
    products.append(.library(name: name, targets: [name]))
    targets.append(
      contentsOf: [
        .target(name: name, dependencies: dependencies),
        .testTarget(name: name + "Tests", dependencies: [.byName(name: name)])
      ]
    )
    return self
  }

  @discardableResult
  func addSwiftSettingsToAllTargets(_ settings: [SwiftSetting]) -> Self {
    for target in targets {
      var swiftSettings = target.swiftSettings ?? []
      swiftSettings.append(contentsOf: [
        .swiftLanguageMode(.v6),
      ])
      target.swiftSettings = swiftSettings
    }
    return self
  }
}
