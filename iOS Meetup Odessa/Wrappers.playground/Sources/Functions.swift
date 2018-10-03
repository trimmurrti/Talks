import Foundation

public func scope(_ description: String, execute: () -> ()) {
    print("-----------\(description)")
    execute()
}

public func io<Value>(_ value: Value?) {
    print(String(describing: value))
}

public func address<Value: AnyObject>(_ value: Value) -> Int {
    var mutableValue = value
    return withUnsafePointer(to: &mutableValue) {
        $0.withMemoryRebound(to: Int.self, capacity: 1) {
            $0.pointee
        }
    }
}
