import Vapor
import HTTP
import Auth
import Turnstile

final class LoginController {
    func addRoutes(to drop: Droplet) {
        drop.post("login", handler: adminLogin)
        drop.post("register", handler: createAdmin)
    }
    
    func createAdmin(_ request: Request)throws -> ResponseRepresentable {
        guard let username = request.data["username"]?.string,
            let password = request.data["password"]?.string else {
                throw Abort.badRequest
        }
        
        let credentials = UsernamePassword(username: username, password: password)
        
        if var user = try User.register(credentials: credentials) as? User {
            try user.save()
            let userDictionary = ["user": user]
            return try JSON(node: userDictionary)
        } else {
//            return Response(redirect: "/create-admin")
            throw Abort.badRequest
        }
    }
    
    func adminLogin(_ request: Request)throws -> ResponseRepresentable {
        guard let username = request.data["username"]?.string,
            let password = request.data["password"]?.string else {
                throw Abort.badRequest
        }
        
        let credentials = UsernamePassword(username: username, password: password)
        
        if let user = try User.authenticate(credentials: credentials) as? User {
            let userDictionary = ["user": user]
            return try JSON(node: userDictionary)
        } else {
//            return Response(redirect: "/login?succeded=false")
            throw Abort.notFound
        }
        
//        do {
//            try request.auth.login(credentials, persist: true)
//            
//            return Response(redirect: "/admin/new-post")
//        } catch {
//            return Response(redirect: "/login?succeded=false")
//        }
    }
    
}
