import Vapor
import HTTP

let drop = Droplet()
// let v1 = drop.grouped("v1")

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

drop.run()
