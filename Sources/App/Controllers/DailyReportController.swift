//
//  DailyReportController.swift
//  printer-server-io
//
//  Created by Richard Adem on 1/12/17.
//
//

import HTTP
import Vapor
import Turnstile

// drop.config["weather","key"]

final class DailyReportController {
    func addRoutes(to drop: Droplet) {
        drop.get("dailyReport", handler: dailyReport)
    }
    
    func dailyReport(_ request: Request) throws -> ResponseRepresentable {
        
        guard let accessTokenString = request.data["token"]?.string else {
            throw Abort.badRequest
        }
        
        let accessToken = AccessToken(string: accessTokenString)
        guard let user = try User.authenticate(accessToken: accessToken) as? User else {
            throw Abort.badRequest
        }
        
        var report: [String: Node] = [:]
        
        report["username"] = Node.string(user.username)
        
        // Get Weather
        // let date = NSDate(timeIntervalSince1970: 1415637900)
        
        let weather = try Weather.query().filter("id", .greaterThanOrEquals, Weather.query().count() ).first()?.makeNode()
        report["weather"] = weather
        
        // Get Todo list
        report["todo"] = [:]
        
        // Get News
        
        // Get Top tweets
        
        // Get kitten
        
        
        
        
        return try JSON(node: report)
    }
}
