
scope("Unique non-hashable") {
    class User: CustomStringConvertible {
        
        let name: String
        let age: Int
        
        var description: String {
            return "User \(self.name) age \(self.age)"
        }
        
        init(name: String, age: Int) {
            self.name = name
            self.age = age
        }
    }
    
    let olga = User(name: "Olechka", age: 35)
    let ihor = User(name: "Ihor", age: 23)
    let lenia = User(name: "Leonard", age: 7)
    
    let users = [olga, olga, ihor, ihor, lenia]
    var uniqueObjects = [User]()
    users.forEach { user in
        let contains = uniqueObjects.contains { address($0) == address(user) }
        if contains {
            uniqueObjects.append(user)
        }
    }
    
    io(uniqueObjects)
}


class HashableIdentityObject<Value: AnyObject>: Hashable {
    
    let value: Value
    
    init(_ value: Value) {
        self.value = value
    }
    
    var hashValue: Int {
        return address(self.value)
    }
    
    static func == (
        lhs: HashableIdentityObject<Value>,
        rhs: HashableIdentityObject<Value>
    )
        -> Bool
    {
        return lhs.value === rhs.value
    }
    
}

scope("Identity") {
    class User: CustomStringConvertible {
        
        let name: String
        let age: Int
        
        var description: String {
            return "User \(self.name) age \(self.age)"
        }
        
        init(name: String, age: Int) {
            self.name = name
            self.age = age
        }
    }
    
    let olga = User(name: "Olechka", age: 35)
    let ihor = User(name: "Ihor", age: 23)
    let lenia = User(name: "Leonard", age: 7)
    
    let users = [olga, olga, ihor, ihor, lenia]
    let identities = users.map(HashableIdentityObject.init)
    let uniqueUsers = Set(identities).map { $0.value }
    
    
    io(uniqueUsers)
}

enum Tuple {
    
    static func lift<A, B>(_ value: (A?, B?)) -> (A, B)? {
        return value.0.flatMap { a in
            value.1.flatMap { (a, $0) }
        }
    }
    
    static func lift<A, B>(_ a: A?, b: B?) -> (A, B)? {
        return lift((a, b))
    }
}


class Weak<Value: AnyObject>: Equatable {
    
    private(set) weak var value: Value?
    
    init(_ value: Value) {
        self.value = value
    }
    
    static func == (
        lhs: Weak<Value>,
        rhs: Weak<Value>
    )
        -> Bool
    {
        return lhs.value === rhs.value
    }
}

scope("Weak") {

    class User: CustomStringConvertible {

        let name: String
        let age: Int

        var description: String {
            return "User \(self.name) age \(self.age)"
        }

        init(name: String, age: Int) {
            self.name = name
            self.age = age
        }
    }

    let olga = User(name: "Olechka", age: 35)
    let users = [olga, User(name: "Anton", age: 27)].map(Weak.init)
    io(users.map { $0.value })
}
//
//class HashableWeak<Value: AnyObject>: Equatable {
//
//    private(set) weak var value: Value?
//    private let hashValue: Int
//
//    init(_ value: Value) {
//        self.value = value
//        self.hashValue = address(value)
//    }
//
//    static func == (
//        lhs: Weak<Value>,
//        rhs: Weak<Value>
//    )
//        -> Bool
//    {
//        return lhs.value === rhs.value
//    }
//}

scope("Int") {
    class User {
        var likes = 0
    }

    let user = User()

    [1, 1, -1, -1].forEach {
        var likes = user.likes
        likes += $0
        user.likes = likes

        let likesString = likes != 0 ? "\(likes)" : nil
        io(likesString)
    }
}

scope("NonZeroInt") {
    struct NonZeroInt: CustomStringConvertible {
        
        typealias IntTransformer = (Int) -> Int
        
        private let value: Int
        
        var description: String {
            return self.value.description
        }
        
        init?(_ value: Int) {
            if value == 0 {
                return nil
            }
            
            self.value = value
        }
        
        func transform(_ transformer: IntTransformer) -> NonZeroInt? {
            return NonZeroInt(transformer(self.value))
        }
    }
    
    class User {
        var likes: NonZeroInt?
    }
    
    let user = User()
    
    [1, 1, -1, -1].forEach { action in
        let likes = user.likes
        user.likes = likes == nil ? NonZeroInt(action) : likes?.transform { $0 + action }
        io(user.likes)
    }
}

scope("Counter") {
    enum Counter: CustomStringConvertible {
        case number(Int)
        case zero
        
        typealias IntTransformer<Value> = (Int) -> Value
        typealias ZeroTransformer<Value> = () -> Value
        
        var description: String {
            return self.analysis(number: { "\($0)" }, zero: { "" })
        }
        
        init(_ value: Int) {
            self = value == 0 ? .zero : .number(value)
        }
        
        func analysis<Result>(
            number: IntTransformer<Result>,
            zero: ZeroTransformer<Result>
        )
            -> Result
        {
            switch self {
            case let .number(value): return number(value)
            case .zero: return zero()
            }
        }
        
        func transform(_ transformer: IntTransformer<Int>) -> Counter {
            let value = self.analysis(number: { $0 }, zero: { 0 })
            
            return .init(transformer(value))
        }
    }
}
//
//scope("Array") {
//    class User: CustomStringConvertible {
//        let name: String
//        var friends = [User]()
//
//        var description: String {
//            var result = "User \(self.name)"
//            let friends = self.friends
//            if friends.count > 0 {
//                result += ", friends \(friends)"
//            }
//
//            return result
//        }
//
//        init(name: String) {
//            self.name = name
//        }
//    }
//
//    let user = User(name: "Vasia")
//    user.friends = ["Irynka", "Petro"].map(User.init)
//
//    io(user)
//}
//
////protocol OptionalRepresentable {
////}
//
////struct OptionalTransformer<Value: OptionalRepresentable> {
////}
//
////protocol OptionalTransformable: OptionalRepresentable {
////}
//
////extension OptionalTransformable {
////}
//
////protocol EmptyOptionalRepresentable: OptionalRepresentable {
////}
//
////extension EmptyOptionalRepresentable {
////}
//
////typealias EmptyOptionalTransformable = EmptyOptionalRepresentable & OptionalTransformable
//
////extension Array: EmptyOptionalTransformable {
////}
//
////extension String: EmptyOptionalTransformable {
////}
//
//scope("Transformer") {
////    class User: CustomStringConvertible {
////        let name: String
////        var friends = [User]()
////
////        var description: String {
////            ???
////        }
////
////        init(name: String) {
////            self.name = name
////        }
////    }
////
////    let user = User(name: "Vasia")
////    user.friends = ["Irynka", "Petro"].map(User.init)
////
////    io(user)
//}

