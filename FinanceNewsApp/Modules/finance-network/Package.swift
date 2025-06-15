// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "finance-network",
  platforms: [.iOS(.v18)],
  products: [
    .library(
      name: "FinanceNetwork",
      targets: ["FinanceNetwork"]),
  ],
  targets: [
    .target(
      name: "FinanceNetwork"),
    .testTarget(
      name: "FinanceNetworkTests",
      dependencies: ["FinanceNetwork"],
      resources: [
          .copy("JSON/TrendingNews.json"),
          .copy("JSON/TrendingNewsList.json"),
      ]
    ),
  ]
)
