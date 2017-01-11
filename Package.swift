import PackageDescription

let package = Package(
    name: "printer-server-io",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 3),
        .Package(url: "https://github.com/vapor/postgresql-provider", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/siemensikkema/vapor-jwt.git", majorVersion: 0, minor: 6)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
        "Tests",
    ]
)

