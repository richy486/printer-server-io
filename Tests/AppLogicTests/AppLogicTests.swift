import XCTest

import Core
import HTTP

@testable import Vapor
@testable import AppLogic

class AppLogicTests: XCTestCase {
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the
//        var p = Post(content: "Hello, World!")
//        XCTAssertEqual(p.content, "Hello, World!")
//    }
    
    static var allTests = [
        ("testExampleEndpoint", testExampleEndpoint)
    ]
    
    func testExampleEndpoint() throws {
        let drop = try makeDroplet()
        let request = try Request(method: .get, uri: "/test")
        
        let response = try drop.respond(to: request)
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(response.body.bytes?.string, "Hello, World!")
    }
}

extension AppLogicTests {
    func makeDroplet() throws -> Droplet {
        let drop = Droplet(arguments: ["/dummy/path/", "prepare"])
        try setup(drop)
        try drop.runCommands()
        return drop
    }
}
