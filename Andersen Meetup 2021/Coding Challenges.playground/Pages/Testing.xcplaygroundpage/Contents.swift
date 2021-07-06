class User {
    var age = 0
}

class Facebook {
    class func login() -> (id: String, email: String) { ("id", "email") }
}

struct API {
    static let shared = API()
    
    func createUser(_ id: String, _ email: String) -> User { .init() }
}

class Database {
    static func store(_ user: User) {  }
}

class ViewController {
    func onButton() {
        let (id, email) = Facebook.login()
        let user = API.shared.createUser(id, email)
        user.age = 30
        
        Database.store(user)
    }
}


