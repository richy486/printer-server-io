import HTTP
import Vapor

final class TodoController {
    func addRoutes(to drop: Droplet) {
        
        drop.group("todo") { todo in
            todo.post("creat", handler: create)
        }
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var post = try request.post()
        try post.save()
        return post
    }
}
