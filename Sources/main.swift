//
//  main.swift
//  printer-server-io
//
//  Created by Richard Adem on 8/30/16.
//  Copyright © 2016 Richard Adem. All rights reserved.
//

import Foundation
import Vapor

//print("PrinterServerIO -- starting")
//
//Router.get("Hello") { _ in
//    return ["Hello": "World"]
//}
//
//let server = Server()
//server.run(port: 8080)


let drop = Droplet()

drop.get("hello") { request in
    return "Hello, world!"
}



drop.serve()
