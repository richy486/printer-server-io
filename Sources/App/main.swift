import Vapor
import HTTP

let drop = Droplet()

drop.get("hello") { request in
  let name = request.data["name"]?.string ?? "stranger"
  return try drop.view.make("hello", [
    "name": name
  ])
}

drop.post("person") { request in
  guard let name = request.data["name"]?.string,
        let city = request.data["city"]?.string else {
    throw Abort.badRequest
  }

  return try Response(status: .created, json: JSON(node: [
    "name": name,
    "city": city
  ]))
}

drop.get("something") { request in
  let name = request.data["name"]?.string ?? "stranger"
  return try Response(status: .created, json: JSON(node: [
    "name": name,
    "something": true
  ]))
}

drop.run()
