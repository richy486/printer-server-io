//{ "title": {{Title}}, "notes": {{Notes}}, "list": {{List}}, "priority": {{Priority}}, "creationDate": {{CreatedDate}} }

import Vapor
import Fluent
import Foundation

final class Todo: Model {

    var exists: Bool = false
    var id: Node?
    var title: String
    var notes: String
    var creationDate: Int
    
    init(title: String, notes: String, creationDate: Int) {
        self.id = UUID().uuidString.makeNode()
        self.title = title
        self.notes = notes
        self.creationDate = creationDate
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
        notes = try node.extract("notes")
        creationDate = try node.extract("creationDate")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "title": title,
            "notes": notes,
            "creationDate": creationDate
        ])
    }
}

extension Todo: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("todos") { todo in
            todo.id()
            todo.string("title")
            todo.string("notes")
            todo.int("creationDate")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("todos")
    }
}
