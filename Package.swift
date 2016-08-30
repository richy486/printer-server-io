//
//  Package.swift
//  printer-server-io
//
//  Created by Richard Adem on 8/30/16.
//  Copyright © 2016 Richard Adem. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "PrinterServerIO",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 0)
    ]
)
