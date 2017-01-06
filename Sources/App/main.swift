import Vapor
import HTTP

let drop = Droplet()

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
    
    v2.get("friends") { req in
        let friends = [Friend(name: "Sarah", age: 33, email:"sarah@email.com"),
                       Friend(name: "Steve", age: 31, email:"steve@email.com"),
                       Friend(name: "Drew", age: 35, email:"drew@email.com")]
        let friendsNode = try friends.makeNode()
        let nodeDictionary = ["friends": friendsNode]
        return try JSON(node: nodeDictionary)
    }
    
    v2.resource("posts", PostController())
}

drop.run()
