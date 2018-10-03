import Foundation

extension NSLocking {
    
    func `do`<Result>(action: () -> Result) -> Result {
        self.lock()
        defer { self.unlock() }
        
        return action()
    }
}

protocol Lockable: NSLocking { }
extension NSLock: Lockable { }
extension NSRecursiveLock: Lockable { }

class Atomic<Wrapped> {
    
    // MARK: -
    // MARK: Subtypes
    
    typealias Value = Wrapped
    typealias Observer = ((old: Value, new: Value)) -> ()
    
    // MARK: -
    // MARK: Static
    
    static func recursive(_ value: Value, observer: Observer? = nil)
        -> Atomic<Value>
    {
        return .init(value, lock: NSRecursiveLock(), observer: observer)
    }
    
    static func lock(_ value: Value, observer: Observer? = nil)
        -> Atomic<Value>
    {
        return .init(value, lock: NSLock(), observer: observer)
    }
    
    // MARK: -
    // MARK: Properties
    
    var value: Value {
        get { return self.transform { $0 } }
        set { self.modify { $0 = newValue } }
    }
    
    private let lock: Lockable
    private let observer: Observer?
    
    private var mutableValue: Value
    
    // MARK: -
    // MARK: Init and Deinit
    
    init(
        _ value: Value,
        lock: Lockable,
        observer: Observer? = nil
        ) {
        self.mutableValue = value
        self.lock = lock
        self.observer = observer
    }
    
    // MARK: -
    // MARK: Public
    
    func modify<Result>(
        _ action: (inout Value) -> Result
        )
        -> Result
    {
        return self.lock.do {
            let oldValue = self.mutableValue
            
            defer {
                self.observer?((oldValue, self.mutableValue))
            }
            
            return action(&self.mutableValue)
        }
    }
    
    func transform<Result>(
        _ action: (Value) -> Result
        )
        -> Result
    {
        return self.lock.do {
            action(self.mutableValue)
        }
    }
}

struct ID {
    
    // MARK: -
    // MARK: Properties
    
    let value: Int
    
    // MARK: -
    // MARK: Init and Deinit
    
    init(_ value: Int) {
        self.value = value
    }
    
    init?(string: String) {
        guard
            let value = Int(string)
            else {
                return nil
        }
        self.init(value)
    }
}

extension ID: Comparable {
    
    static func ==(lhs: ID, rhs: ID) -> Bool {
        return lhs.value == rhs.value
    }
    
    static func <(lhs: ID, rhs: ID) -> Bool {
        return lhs.value < rhs.value
    }
}

extension ID: Hashable {
    
    var hashValue: Int {
        return self.value.hashValue
    }
}

extension ID: CustomStringConvertible {
    
    var description: String {
        return self.value.description
    }
}

extension ID: ExpressibleByIntegerLiteral {
    
    init(integerLiteral value: Int) {
        self.init(value)
    }
}

func call<Result>(_ function: () -> Result) -> Result {
    return function()
}

extension ID {
    
    typealias Provider = () -> ID
}

extension UserDefaults {
    
    func write(_ action: (UserDefaults) -> ()) {
        action(self)
        self.synchronize()
    }
}

fileprivate let persistentProviders = Atomic.lock([String: ID.Provider]())

func autoincrementedID(start: Int) -> ID.Provider {
    return autoincrementedID(start)
}

func autoincrementedID(key: String) -> ID.Provider {
    return persistentProviders.modify { storage in
        storage[key] ?? call {
            let defaults = UserDefaults.standard
            
            let result = autoincrementedID(defaults.integer(forKey: key)) { id in
                defaults.write { $0.set(id, forKey: key) }
            }
            
            storage[key] = result
            
            return result
        }
    }
}

func autoincrementedID(
    _ start: Int,
    didSet: ((_ newValue: Int) -> ())? = nil
)
    -> ID.Provider
{
    let value = Atomic.lock(start)
    
    return {
        value.modify {
            let result = $0
            $0 += 1
            didSet?($0)
            
            return ID(result)
        }
    }
}

let provider = autoincrementedID(10)
provider().value
provider().value

