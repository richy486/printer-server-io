import Foundation
import Vapor
import VaporPostgreSQL
import Fluent
import Auth
import Turnstile
import BCrypt
import VaporJWT

struct Authentication {
    static let AccessTokenSigningKey: Bytes = Array("CHANGE_ME".utf8)
    static let AccesTokenValidationLength = Date() + (60 * 5) // 5 Minutes later
}

final class User {
    var exists: Bool = false
    var id: Node?
    var username: String!
    var password: String!
    var accessToken:String?
    
    init(username: String, password: String) {
        self.id = nil
        self.username = username
        self.password = BCrypt.hash(password: password)
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        username = try node.extract("username")
        password = try node.extract("password")
        accessToken = try node.extract("access_token")
    }
    
    init(credentials: UsernamePassword) {
        self.username = credentials.username
        self.password = BCrypt.hash(password: credentials.password)
    }
    
    init(credentials: Auth.AccessToken) {
        self.accessToken = credentials.string
    }
}

extension User: Model {
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "username": username,
            "password": password,
            "access_token": accessToken
            ])
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("users", closure: { (user) in
            user.id()
            user.string("username")
            user.string("password")
            user.string("access_token")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
}

extension User: Auth.User {
    
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        
        var user: User?
        
        switch credentials {
        case let usernamePassword as UsernamePassword:
            
            guard let fetchedUser = try User.query().filter("username", usernamePassword.username).first() else {
                throw Abort.custom(status: .networkAuthenticationRequired, message: "User does not exist")
            }
            
            guard try BCrypt.verify(password: usernamePassword.password, matchesHash: fetchedUser.password) else {
                throw Abort.custom(status: .networkAuthenticationRequired, message: "Invalid user name or password.")
            }
            
            user = fetchedUser

        case let id as Identifier:
            guard let fetchedUser = try User.find(id.id) else {
                throw Abort.custom(status: .forbidden, message: "Invalid user identifier.")
            }
            
            user = fetchedUser
            
        case let accessToken as AccessToken:
            guard let fetchedUser = try User.query().filter("access_token", accessToken.string).first() else {
                throw Abort.custom(status: .forbidden, message: "Invalid access token.")
            }
            
            user = fetchedUser
            
        default:
            let type = type(of: credentials)
            throw Abort.custom(status: .forbidden, message: "Unsupported credential type: \(type).")
        }
        
        if var user = user {
            // Check if we have an accessToken first, if not, lets create a new one
            if let accessToken = user.accessToken {
                // Check if our authentication token has expired, if so, lets generate a new one as this is a fresh login
                let receivedJWT = try JWT(token: accessToken)
                
                // Validate it's time stamp
                if !receivedJWT.verifyClaims([ExpirationTimeClaim()]) {
                    try user.generateToken()
                }
            } else {
                // We don't have a valid access token
                try user.generateToken()
            }
            
            try user.save()
            
            return user
        } else {
            throw IncorrectCredentialsError()
        }
    }
    static func register(credentials: Credentials) throws -> Auth.User {
        
        guard let usernamePassword = credentials as? UsernamePassword else {
            let type = type(of: credentials)
            throw Abort.custom(status: .forbidden, message: "Unsupported credential type: \(type).")
        }
        
        let user = User(username: usernamePassword.username, password: usernamePassword.password)
        
        if try User.query().filter("username", user.username).first() == nil {
            try user.generateToken()
//            try user.save()
            return user
        } else {
            throw AccountTakenError()
        }
    }
}

// MARK: Token Generation
extension User {
    func generateToken() throws {
        // Generate our Token
        let jwt = try JWT(payload: Node(ExpirationTimeClaim(Authentication.AccesTokenValidationLength)), signer: HS256(key: Authentication.AccessTokenSigningKey))
        self.accessToken = try jwt.createToken()
    }
    
    func validateToken() throws -> Bool {
        guard let token = self.accessToken else { return false }
        
        // Validate our current access token
        let receivedJWT = try JWT(token: token)
        if try receivedJWT.verifySignatureWith(HS256(key: Authentication.AccessTokenSigningKey)) {
            
            // If we need a new token, lets generate one
            if !receivedJWT.verifyClaims([ExpirationTimeClaim()]) {
                try self.generateToken()
                return true
            }
        }
        return false
    }
}
