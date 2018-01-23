import Foundation


// Uncle Bob level ugly bools

func printMama() {
    print("mama")
}

func f(x: Int) -> Bool {
    if (x == 1) {
        printMama()

        return true
    } else {
        return false
    }
}

func scope(action: () -> ()) {
    action()
}

scope {
    func f(x: Int) -> Bool {
        if (x == 1) {
            printMama()
            
            return true
        } else {
            return false
        }
    }
}

scope {
    func f(x: Int) -> Bool {
        let result = x == 1
        if (result) {
            printMama()
        }

        return result
    }
}

func ignoreInput<Value, Result>(action: @escaping () -> Result) -> (Value) -> Result {
    return { _ in
        action()
    }
}

func sideEffect<Value>(action: @escaping (Value) -> ()) -> (Value) -> Value {
    return {
        action($0)
        
        return $0
    }
}

precedencegroup LeftFunctionApplicationPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

precedencegroup RightFunctionApplicationPrecedence {
    associativity: right
    higherThan: LeftFunctionApplicationPrecedence
}

precedencegroup LeftCompositionPrecedence {
    associativity: left
    higherThan: RightFunctionApplicationPrecedence
}

infix operator |> :LeftFunctionApplicationPrecedence
infix operator <| :RightFunctionApplicationPrecedence
infix operator § :RightFunctionApplicationPrecedence
infix operator • :LeftCompositionPrecedence

func § <Value, Result>(transform: (Value) -> Result, value: Value) -> Result {
    return transform(value)
}

func |> <Value, Result>(value: Value, transform: (Value) -> Result) -> Result {
    return transform § value
}

func <| <Value, Result>(transform: (Value) -> Result, value: Value) -> Result {
    return transform § value
}

func • <A, B, C>(lhs: @escaping (A) -> B, rhs: @escaping (B) -> C) -> (A) -> C {
    return { rhs(lhs($0)) }
}

func stringify<Value: CustomStringConvertible>(value: Value) -> String {
    return value.description
}

func stringify<Value>(value: Value) -> String {
    return "\(value)"
}

let print = { Swift.print($0) }

func test(action: @escaping (Int) -> Bool) {
    [1, 3, 100].forEach(action • stringify • print)
    
    print("\n")
}

scope {
    test § { sideEffect(action: ignoreInput(action: printMama))($0 == 1) }
}

scope {
    let ffffuuuuu = { $0 == 1 } • (sideEffect § ignoreInput § printMama)
    test § ffffuuuuu
}

scope {
    func condition<Result>(
        value: Bool,
        `if`: () -> Result,
        `else`: () -> Result
    )
        -> Result
    {
        return value ? `if`() : `else`()
    }
}

scope {
    func condition<Result>(
        value: Bool,
        `if`: () -> Result,
        `else`: () -> Result
    )
        -> Result
    {
        return withoutActuallyEscaping(`if`) { `if` in
            withoutActuallyEscaping(`else`) {
                () |> (value ? `if` : $0)
            }
        }
    }
}

func call<Result>(action: () -> Result) -> Result {
    return action()
}

func lambda<Result>(action: @escaping () -> Result) -> () -> Result {
    return action
}

struct S {
    let value = call {
        /*
         asrfaswf
         asrfaswf
         asrfaswf
         asrfaswf
         asrfaswf
         asrfaswf
         asrfaswf
        */
        
        return 1
    }
}

scope {
    func condition<Result>(
        value: Bool,
        `if`: () -> Result,
        `else`: () -> Result
    )
        -> Result
    {
        return withoutActuallyEscaping(`if`) { `if` in
            withoutActuallyEscaping(`else`) {
                call § (value ? `if` : $0)
            }
        }
    }
}

func condition<Result>(
    value: Bool,
    `if`: () -> Result,
    `else`: () -> Result
)
    -> Result
{
    return value ? `if`() : `else`()
}

scope {
    let ffffuuuuu = { $0 == 1 } • (sideEffect § {
        condition(value: $0, if: printMama, else: { () })
    })
    
    test § ffffuuuuu
}

func returnValue<Value>(value: Value) -> () -> Value {
    return { value }
}

scope {
    let ffffuuuuu = { $0 == 1 } • (sideEffect § {
        condition(value: $0, if: printMama, else: returnValue § ())
    })
    
    test § ffffuuuuu
}

func when<Result>(value: Bool, action: () -> Result) -> Result? {
    return value ? action() : nil
}

// when with explicit nil (callIf -> became when thx to Paul Taykalo)
// when with returnValue

// Useful as well:
// ignoreAndReturn
// unless

// Solution using uncurried when

scope {
    let ffffuuuuu = { $0 == 1 } • (sideEffect § { when(value: $0, action: printMama) })
    
    test § ffffuuuuu
}

func curry<A, B, C>(action: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in
        { action(a, $0) }
    }
}

func flip<A, B, C>(action: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    return { b in
        { action($0)(b) }
    }
}

func ignoreOutput<Value, Result>(action: @escaping (Value) -> Result) -> (Value) -> () {
    return { _ = action($0) }
}

func equals<Value: Equatable>(_ lhs: Value) -> (Value) -> Bool {
    return { lhs == $0 }
}

scope {
    let ffffuuuuu = (1 |> equals) • (sideEffect § ignoreOutput § (when |> curry |> flip) § printMama)
    test § ffffuuuuu
}

func less<Value: Comparable>(_ lhs: Value) -> (Value) -> Bool {
    return { lhs < $0 }
}

// Solution using curried when

// Additional example
// greater
// curried greater to less


// eDSL using trailing closures

// extract
//func outerCall(_ action: () -> ()) {
//    // do something before
//    action()
//    // do something after
//}

// adjust
//struct Value {
//    var x: Int
//}
//
//let values = [1, 2].map(Value.init)
//let result: [Value] = values.map {
//    var value = $0
//    value.x += 1
//
//    return value
//}

// tuple with optionals
//let printInts: (Int, Int) -> () = {
//    print("x1 = \($0), x2 = \($1)")
//}
//
//let x1: Int? = 1
//let x2: Int? = 2
//
//if
//    let x1 = x1,
//    let x2 = x2
//{
//    printInts(x1, x2)
//}

// lift tuple, lift to tuple
// Optional+do


// Namespaced eDSL
//    iOS.device { print("DO SOME METAL PROCESSING USING BLE") }
//    iOS.simulator § printMama
//Platform
//    mobile -> arch(arm) || arch(arm64)
//    mac -> arch(i386) || arch(x86_64)
//OS
//    iOS -> os(iOS)
//    macOS -> os(macOS)

// ~>

// iOS
//    device
//    simulator

// Namespaced Constrained eDSL
//iOS.do(
//    device: { print("DO SOME METAL PROCESSING USING BLE") },
//    simulator: printMama,
//    none: { }
//)
//
//let deviceOne = extract(iOS.simulator) { 1 }
//print(deviceOne ?? -1)
//
//let simulatorOne = extract(Platform.mac ~> OS.iOS) { 1 }
//print(simulatorOne ?? -1)

//protocol SumType: Equatable
//SumType + do
//~> SumType


//enum Platform: SumType
//enum OS: SumType
//enum iOS: SumType -> device | simulator | none


// Holder DSL
//let user = User(name: "Vasia")
//print(user.dsl.renamed(to: "Ganzolder"))


//DSL<Base>
//DSLProvider
//DSLProvider + dsl
//User: DSLProvider

//DSL + adjust
//DSL<User> + renamed

//Declarative DSL - see IDPDesignable
//Non-constrained syntax DSL - see SnapKit
//Constrained syntax DSL - see Nimble-
