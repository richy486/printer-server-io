import Vapor
import Fluent
import Foundation

// Icons: https://openweathermap.org/weather-conditions

final class Weather: Model {
    var exists: Bool = false
    var id: Node?
    var day: String
    var title: String
    var description: String
    var iconId: String
    var avgTemprature: Double
    var minTemprature: Double
    var maxTemprature: Double
    
    init(day: String, title: String, description: String, avgTemprature: Double, minTemprature: Double, maxTemprature: Double, iconId: String) {
        self.id = UUID().uuidString.makeNode()
        self.day = day
        self.title = title
        self.description = description
        self.iconId = iconId
        self.avgTemprature = avgTemprature
        self.minTemprature = minTemprature
        self.maxTemprature = maxTemprature
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        day = try node.extract("day")
        title = try node.extract("title")
        description = try node.extract("description")
        iconId = try node.extract("iconid")
        avgTemprature = try node.extract("avgtemprature")
        minTemprature = try node.extract("mintemprature")
        maxTemprature = try node.extract("maxtemprature")
    }
    
    init(openWeatherJson json: JSON) throws {
        
        
        
        
        
//        id = UUID().uuidString.makeNode()
        self.id = nil
        
//        let forcastDay = try (node.extract("list") as? Array).first


        guard let forcastDay = json["list"]?.array?[0] as? JSON else { throw Abort.badRequest }
        guard let day = forcastDay["dt"]?.string else { throw Abort.badRequest }
        self.day = day
        
//        let forcastDay = (json["list"]?[0])!
//        day = forcastDay["dt"]!
        
        guard let weather = forcastDay["weather"]?.array?[0] as? JSON else { throw Abort.badRequest }    //try forcastDay.extract("weather")[0]
        
        guard let title = weather["main"]?.string else { throw Abort.badRequest }      //try weather.extract("main")
        self.title = title
        
//        description = ""//try weather.extract("description")
        guard let description = weather["description"]?.string else { throw Abort.badRequest }      //try weather.extract("main")
        self.description = description
        
        
//        iconId = ""//try weather.extract("icon")
        guard let iconId = weather["icon"]?.string else { throw Abort.badRequest }      //try weather.extract("main")
        self.iconId = iconId
        
//        let temprature = ""//try forcastDay.extract("temp")
        guard let temprature = forcastDay["temp"]?.object else { throw Abort.badRequest }
        
        
//        avgTemprature = ""//try temprature.extract("day")
        guard let avgTemprature = temprature["day"]?.double else { throw Abort.badRequest }      //try weather.extract("main")
        self.avgTemprature = avgTemprature
        
        
//        minTemprature = ""//try temprature.extract("min")
        guard let minTemprature = temprature["min"]?.double else { throw Abort.badRequest }      //try weather.extract("main")
        self.minTemprature = minTemprature
        
//        maxTemprature = ""//try temprature.extract("max")
        guard let maxTemprature = temprature["max"]?.double else { throw Abort.badRequest }      //try weather.extract("main")
        self.maxTemprature = maxTemprature
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "day": day,
            "title": title,
            "description": description,
            "iconId": iconId,
            "avgTemprature": avgTemprature,
            "minTemprature": minTemprature,
            "maxTemprature": maxTemprature
            ])
    }
}

//extension Weather {
//    /**
//     This will automatically fetch from database, using example here to load
//     automatically for example. Remove on real models.
//     */
//    public convenience init?(from string: String) throws {
//        self.init(content: string)
//    }
//}

extension Weather: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("weathers") { weather in
            weather.id()
            weather.string("day")
            weather.string("title")
            weather.string("description")
            weather.string("iconId")
            weather.double("avgTemprature")
            weather.double("minTemprature")
            weather.double("maxTemprature")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("weathers")
    }
}
