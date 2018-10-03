import Foundation

protocol Cancellable {
    func cancel()
}

class CancellableProperty<Value: Cancellable> {
    
    public var value: Value? {
        willSet { value?.cancel() }
    }
}

struct Request: Cancellable {
    
    func cancel() {
        print("cancelled \(self)")
    }
}

struct Service {
    let request = CancellableProperty<Request>()
}

let service = Service()
service.request.value = Request()
service.request.value = Request()

infix operator <~ : AssignmentPrecedence
prefix operator ^
postfix operator ^

protocol Wrappable: AnyObject {
    associatedtype Wrapped
    
    var value: Wrapped { get set }
    
    static func <~(wrapper: Self, value: Self.Wrapped)
    prefix static func ^(wrapper: Self) -> Self.Wrapped
    postfix static func ^(wrapper: Self) -> Self.Wrapped
}

extension Wrappable {
    
    static func <~(wrapper: Self, value: Self.Wrapped) {
        wrapper.value = value
    }
    
    prefix static func ^(wrapper: Self) -> Self.Wrapped {
        return wrapper.value
    }
    
    postfix static func ^(wrapper: Self) -> Self.Wrapped {
        return wrapper.value
    }
}

extension CancellableProperty: Wrappable { }

extension Optional {
    func `do`(_ action: (Wrapped) -> ()) {
        self.map(action)
    }
}

service.request <~ Request()
let request = ^service.request
service.request^.do { $0.cancel() }

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
    
    static func recursive(_ value: Value, observer: Observer? = nil) -> Atomic<Value> {
        return Atomic(value, lock: NSRecursiveLock(), observer: observer)
    }
    
    static func lock(_ value: Value, observer: Observer? = nil) -> Atomic<Value> {
        return Atomic(value, lock: NSLock(), observer: observer)
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
    
    func modify<Result>(_ action: (inout Value) -> Result) -> Result {
        return self.lock.do {
            let oldValue = self.mutableValue
            
            defer {
                self.observer?((oldValue, self.mutableValue))
            }
            
            return action(&self.mutableValue)
        }
    }
    
    func transform<Result>(_ action: (Value) -> Result) -> Result {
        return self.lock.do { action(self.mutableValue) }
    }
}

extension Wrappable where Self.Wrapped: Wrappable {
    
    static func <~(wrapper: Self, value: Wrapped.Wrapped) {
        wrapper.value <~ value
    }
    
    prefix static func ^(wrapper: Self) -> Wrapped.Wrapped {
        return ^wrapper.value
    }
    
    postfix static func ^(wrapper: Self) -> Wrapped.Wrapped {
        return ^wrapper.value
    }
}

extension Atomic: Wrappable { }

let atomicCancellableRequest = Atomic.lock(CancellableProperty<Request>())
atomicCancellableRequest <~ Request()
