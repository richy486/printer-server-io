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
        guard let weatherResponse = try? drop.client.get(url) else {
            throw Abort.badRequest
            
        }
        
        guard let json = weatherResponse.json else {
            throw Abort.badRequest
        }
        
        guard var weather = try? Weather(openWeatherJson: json) else {
            throw Abort.badRequest
        }
        
        if try Weather.query().filter("day", weather.day).first() == nil {
            try weather.save()
        } else {
            // replace this entry
        }
        
        if let saved = try Weather.query().filter("day", weather.day).first() {
            return try saved.makeJSON()
        } else {
            throw Abort.custom(status: .notFound, message: "weather not found after save")
        }
        
        
        
        
//        return weatherResponse
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
