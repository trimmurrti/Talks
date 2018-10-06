import Foundation

scope("Array") {
    class User: CustomStringConvertible {
        var name: String?
        var friends: [User]?
        
        var description: String {
            var result = "User \(self.name ?? "")"
            let friends = self.friends
            if ((friends?.count).map { $0 > 0 } ?? false) {
                result += ", friends \(friends ?? [])"
            }
            
            return result
        }
        
        init(name: String) {
            self.name = name
        }
    }
    
    let user = User(name: "Vasia")
    user.friends = ["Irynka", "Petro"].map(User.init)
    
    io(user)
}

protocol Emptiable {
    
    static func materialize(_ value: Self?) -> Self
    static var `default`: Self { get }
    
    var isEmpty: Bool { get }
    var optional: Self? { get }
    
    var transformer: EmptyTransformer<Self> { get }
}

extension Emptiable {
    static func materialize(_ value: Self?) -> Self {
        return value ?? Self.default
    }
    
    var optional: Self? {
        return self.isEmpty ? nil : self
    }
    
    var transformer: EmptyTransformer<Self> {
        return .init(self)
    }
}

struct EmptyTransformer<T: Emptiable> {
    
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    func map<R>(_ ƒ: (T) -> R) -> EmptyTransformer<R> {
        return self.flatMap(ƒ)
    }
    
    func flatMap<R>(_ ƒ: (T) -> R?) -> EmptyTransformer<R> {
        return .init(.materialize(ƒ(self.value)))
    }
}

extension String: Emptiable {
    
    static var `default`: String {
        return ""
    }
}

extension Array: Emptiable {
    
    static var `default`: Array {
        return []
    }
}

extension Set: Emptiable {
    
    static var `default`: Set {
        return .init()
    }
}

scope("Transformer") {
    class User: CustomStringConvertible {
        var name = ""
        var friends = [User]()
        
        var description: String {
            var result = "User \(self.name ?? "")"
            let f = self.friends
                .transformer
                .map { ", friends \($0)" }
                .value
            
            return result
        }
        
        init(name: String) {
            self.name = name
        }
    }
    
    let user = User(name: "Vasia")
    user.friends = ["Irynka", "Petro"].map(User.init)
    
    io(user)
}

enum F {
    typealias Transform<Value, Result> = (Value) -> Result
    typealias Void<Result> = () -> Result
    
    static func id<T>(_ x: T) -> T {
        return x
    }
}

typealias Transformer<Value, Result> = (Value) -> Result

struct User {
    
    enum Christianity {
        case orthodox
        case catholic
    }
    
    enum Muslimity {
        case sunna
        case shia
        
        func transform<R>(
            sunna: F.Void<R>,
            shia: F.Void<R>
        )
            -> R
        {
            switch self {
            case .sunna: return sunna()
            case .shia: return shia()
            }
        }
    }
    
    enum Religion {
        case christian(Christianity)
        case muslim(Muslimity)
        case judaism
        
        func transform<R>(
            christian: F.Transform<Christianity, R>,
            muslim: F.Transform<Muslimity, R>,
            judaism: F.Void<R>
        )
            -> R
        {
            switch self {
            case let .christian(type): return christian(type)
            case let .muslim(type): return muslim(type)
            case .judaism: return judaism()
            }
        }
        
        func transform<R>(
            sunna: F.Void<R>,
            shia: F.Void<R>
        )
            -> R?
        {
            switch self {
            case let .christian(type): return nil
            case let .muslim(type):
                return type.transform(sunna: sunna, shia: shia)
            case .judaism: return nil
            }
        }
    }
    
    enum Belief {
        case believer(Religion)
        case atheist
    }
    
    enum Programming {
        case objc
        case shit
    }
    
    enum Camel {
        case yes
        case no
        case sometimes
    }
    
    enum Spouse: CustomStringConvertible {
        typealias Users = Set<User>
        
        case asexual
        case sexual(Users)
        
        var description: String {
            return self.transform(asexual: .init, sexual: .init(describing:))
        }
        
        var partners: Users {
            return self.transform(asexual: .init, sexual: F.id)
        }
        
        func transform<R>(
            asexual: F.Void<R>,
            sexual: F.Transform<Users, R>
        )
            -> R
        {
            switch self {
            case let .sexual(users): return sexual(users)
            case .asexual: return asexual()
            }
        }
    }
    
    let spouses: Spouse
    let belief: Belief
    let programmingLanguages: Set<Programming>
    let sex: Camel
}

let spouse = User.Spouse.asexual
print()
