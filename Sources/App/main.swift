import Vapor
import AppLogic
import HTTP
import VaporPostgreSQL

let drop = Droplet()
drop.preparations.append(Friend.self)
drop.preparations.append(User.self)
drop.preparations.append(Weather.self)

try setup(drop)

//let configDirectory = workingDirectory.finished(with: "/") + "Config/"
//let config = try Settings.Config(
//    prioritized: [
//        .commandLine,
//        .directory(root: configDirectory + "secrets"),
//        .directory(root: configDirectory + "weather"),
//        .directory(root: configDirectory)
//    ]
//)

do {
    try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
    assertionFailure("Error adding provider: \(error)")
}

let loginController = LoginController()
loginController.addRoutes(to: drop)

let weatherController = WeatherController()
weatherController.addRoutes(to: drop)

drop.get { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "title"]
        ])
}

drop.group("v1") { v1 in

  v1.get("hello") { request in
    let name = request.data["name"]?.string ?? "stranger"
    return try drop.view.make("hello", [
      "name": name
    ])
  }

  v1.post("person") { request in
    guard let name = request.data["name"]?.string,
          let city = request.data["city"]?.string else {
      throw Abort.badRequest
    }

    return try Response(status: .created, json: JSON(node: [
      "name": name,
      "city": city
    ]))
  }

  v1.get("something") { request in
    let name = request.data["name"]?.string ?? "stranger"
    return try Response(status: .created, json: JSON(node: [
      "name": name,
      "something": true
    ]))
  }

}

drop.group("v2") { v2 in
    
    /*
     Get Postgres:
     $ brew install postgres
     
     Setup/Start Postgres in terminal 1:
     $ postgres -D /usr/local/var/postgres/
     
     Create Postgres database in terminal 2:
     $ createdb printerDB
     
     View Postgress database in terminal 2:
     $ psql printerDB
     
     Test post in terminal 3:
     $ curl -H "Content-Type: application/json" -X POST -d '{"name": "Some Name","age": 30,"email": "email@email.com"}' http://localhost:8080/v2/friend
     */
    
    v2.get("friends") { req in
        let friends = try Friend.all().makeNode()
        let friendsDictionary = ["friends": friends]
        return try JSON(node: friendsDictionary)
    }
    
    v2.get("friends", Int.self) { req, userID in
        guard let friend = try Friend.find(userID) else {
            throw Abort.notFound
        }
        return try friend.makeJSON()
    }
    
    v2.post("friend") { req in
        print("req: \(req)")
        print("req.json: \(req.json)")
        
        var friend = try Friend(node: req.json)
        try friend.save()
        return try friend.makeJSON()
    }
    
    v2.resource("posts", PostController())
    
    v2.get("weather") { req in
        let allWeather = try Weather.all().makeNode()
        let allWeatherDictionary = ["weathers": allWeather]
        return try JSON(node: allWeatherDictionary)
    }
}

drop.group("v3") { v3 in
    
}

drop.run()
