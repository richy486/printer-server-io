import HTTP
import Vapor

final class TodoController {
    func addRoutes(to drop: Droplet) {
        
        drop.group("todo") { todo in
            todo.post("create", handler: create)
        }
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var todo = try request.todo()
        try todo.save()
        return todo
    }
}

extension Request {
    func todo() throws -> Todo {
        guard let json = json else { throw Abort.badRequest }
        return try Todo(node: json)
    }
}
