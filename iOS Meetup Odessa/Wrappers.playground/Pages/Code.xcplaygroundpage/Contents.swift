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
        
        typealias IntTransform = (Int) -> Int
        
        var description: String {
            return self.value.description
        }
        
        private let value: Int
        
        init?(_ value: Int) {
            if value == 0 {
                return nil
            }
            
            self.value = value
        }
        
        func transform(_ operation: IntTransform) -> NonZeroInt? {
            return NonZeroInt(operation(self.value))
        }
    }
    
    class User {
        var likes: NonZeroInt?
    }
    
    let user = User()
    
    [1, 1, -1, -1].forEach { action in
        let likes = user.likes
        let result = likes == nil ? NonZeroInt(action) : likes?.transform { $0 + action }
        user.likes = result
        
        io(result)
    }
}

scope("Counter") {
    enum Counter: CustomStringConvertible {
        case number(Int)
        case zero
        
        var description: String {
            return self.analysis(number: { "\($0)" }, zero: { "" })
        }
        
        init(_ rawValue: Int) {
            if rawValue == 0 {
                self = .zero
            } else {
                self = .number(rawValue)
            }
        }
        
        func analysis<Result>(number: (Int) -> Result, zero: () -> Result) -> Result {
            switch self {
            case let .number(value): return number(value)
            case .zero: return zero()
            }
        }
        
        func map(_ transform: (Int) -> Int) -> Counter {
            let value = self.analysis(number: transform, zero: { transform(0) })
            
            return Counter(value)
        }
    }
    
    class User {
        var likes = Counter.zero
    }
    
    let user = User()
    
    [1, 1, -1, -1].forEach { action in
        let result = user.likes.map { action + $0 }
        user.likes = result
        
        io(result)
    }
}

scope("Array") {
    class User: CustomStringConvertible {
        let name: String
        var friends = [User]()
        
        var description: String {
            var result = "User \(self.name)"
            let friends = self.friends
            if friends.count > 0 {
                result += ", friends \(friends)"
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

protocol OptionalRepresentable {
    static func representation(optional: Self?) -> Self
    
    var optional: Self? { get }
}

struct OptionalTransformer<Value: OptionalRepresentable> {
    
    let value: Value
    
    init(_ value: Value) {
        self.value = value
    }
    
    func map<Result>(_ transform: (Value) -> Result) -> OptionalTransformer<Result> {
        return self.flatMap { .init(transform($0)) }
    }
    
    func flatMap<Result>(
        _ transform: (Value) -> OptionalTransformer<Result>
    )
        -> OptionalTransformer<Result>
    {
        return .init(
            .representation(
                optional: self.value.optional.map(transform)?.value
            )
        )
    }
}

protocol OptionalTransformable: OptionalRepresentable {
    var transformer: OptionalTransformer<Self> { get }
}

extension OptionalTransformable {
    
    var transformer: OptionalTransformer<Self> {
        return .init(self)
    }
}

protocol EmptyOptionalRepresentable: OptionalRepresentable {
    static var `default`: Self { get }
    
    var isEmpty: Bool { get }
}

extension EmptyOptionalRepresentable {
    
    static func representation(optional: Self?) -> Self {
        return optional ?? self.default
    }
    
    var optional: Self? {
        return self.isEmpty ? nil : self
    }
}

typealias EmptyOptionalTransformable = EmptyOptionalRepresentable & OptionalTransformable

extension Array: EmptyOptionalTransformable {
    static var `default`: Array {
        return []
    }
}

extension String: EmptyOptionalTransformable {
    static var `default`: String {
        return ""
    }
}

scope("Transformer") {
    class User: CustomStringConvertible {
        let name: String
        var friends = [User]()
        
        var description: String {
            return "User \(self.name)" + self.friends
                .transformer
                .map { ", friends \($0)" }
                .value
        }
        
        init(name: String) {
            self.name = name
        }
    }
    
    let user = User(name: "Vasia")
    user.friends = ["Irynka", "Petro"].map(User.init)
    
    io(user)
}

func address<Value: AnyObject>(_ value: Value) -> Int {
    var mutableValue = value
    return withUnsafePointer(to: &mutableValue) {
        $0.withMemoryRebound(to: Int.self, capacity: 1) {
            $0.pointee
        }
    }
}

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
    let uniqueObjects: [User] = users.reduce([]) { result, value in
        let contains = result.contains { address($0) == address(value) }
        
        return result + (contains ? [] : [value])
    }
    
    io(uniqueObjects)
}


class HashableIdentityObject<Value: AnyObject>: Hashable {
    
    static func ==(lhs: HashableIdentityObject<Value>, rhs: HashableIdentityObject<Value>) -> Bool {
        return lhs.value === rhs.value
    }
    
    private(set) var value: Value
    
    init(value: Value) {
        self.value = value
    }
    
    var hashValue: Int {
        return address(self.value)
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
    let uniqueObjects = Set(identities).map { $0.value }
    
    io(uniqueObjects)
}

enum Tuple {
    
    public static func lift<A, B>(_ tuple: (A?, B?)) -> (A, B)? {
        return tuple.0.flatMap { lhs in
            tuple.1.flatMap { (lhs, $0) }
        }
    }
    
    public static func lift<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
        return lift((a, b))
    }
}

class Weak<Value: AnyObject>: Equatable {
    
    private(set) weak var value: Value?
    public var isEmpty: Bool {
        return self.value == nil
    }
    
    init(_ value: Value?) {
        self.value = value
    }
    
    static func == (lhs: Weak<Value>, rhs: Weak<Value>) -> Bool {
        return Tuple.lift(lhs.value, rhs.value).map(===) ?? false
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
    
    let users = [olga, User(name: "Ihor", age: 23)].map(Weak.init)
    
    io(users.map { $0.value })
}
