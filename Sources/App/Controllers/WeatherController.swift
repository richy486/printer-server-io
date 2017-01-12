import HTTP
import Vapor

// drop.config["weather","key"]

final class WeatherController {
    func addRoutes(to drop: Droplet) {
        drop.get("forecast", handler: forecast)
    }
    
    func forecast(_ request: Request) throws -> ResponseRepresentable {
        
        guard let key = drop.config["weather","key"]?.string else {
                throw Abort.badRequest
        }
        
        let url = "http://api.openweathermap.org/data/2.5/forecast/daily?q=NewYork,us&mode=json&units=metric&cnt=1&appid=\(key)"
        let weatherResponse = try drop.client.get(url)
        return weatherResponse
//        
//        let userDictionary = ["forcast": key]
//        return try JSON(node: userDictionary)
    }
}

//
//let configDirectory = workDir.finished(with: "/") + "Config/"
//config = try Settings.Config(
//    prioritized: [
//        .commandLine,
//        .directory(root: configDirectory + "secrets"),
//        .directory(root: configDirectory + environment.description),
//        .directory(root: configDirectory)
//    ]
//)
