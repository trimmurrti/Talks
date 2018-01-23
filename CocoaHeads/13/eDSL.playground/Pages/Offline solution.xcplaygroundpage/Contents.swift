import Foundation

precedencegroup LeftFunctionApplicationPrecedence {
    associativity: left
    higherThan: TernaryPrecedence
}

precedencegroup RightFunctionApplicationPrecedence {
    associativity: right
    higherThan: LeftFunctionApplicationPrecedence
}

infix operator §: RightFunctionApplicationPrecedence

func § <A, B>(f: (A) -> B, x: A) -> B {
    return f(x)
}

infix operator |>: LeftFunctionApplicationPrecedence

func |> <A, B>(x: A, f: (A) -> B) -> B {
    return f(x)
}

infix operator <|: RightFunctionApplicationPrecedence

func <| <A, B>(f: (A) -> B, x: A) -> B {
    return f(x)
}

precedencegroup LeftCompositionPrecedence {
    associativity: left
    higherThan: LeftFunctionApplicationPrecedence
}

infix operator •: LeftCompositionPrecedence

func • <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

func scope(action: () -> ()) {
    action()
}

func scope(_ name: String, action: () -> ()) {
    print("--------------------")
    print(name.uppercased())
    print("\n")
    action()
    print("\n")
}

func printMama() {
    print("mama")
}

scope("Bools") {
    
    scope("Uncle Bob level ugly") {
        func f(x: Int) -> Bool {
            if (x == 1) {
                printMama()
                
                return true
            } else {
                return false
            }
        }
    }
    
    scope("Comparison result to variable") {
        func f(x: Int) -> Bool {
            let result = x == 1
            if result {
                printMama()
            }
            
            return result
        }
    }
    
    scope("DSL") {
        func ignoreInput<Value, Result>(_ f: @escaping () -> Result) -> (Value) -> Result {
            return { _ in f() }
        }
        
        func sideEffect<Value>(_ f: @escaping (Value) -> ()) -> (Value) -> Value {
            return {
                f($0)
                
                return $0
            }
        }
        
        let f: (Int) -> Bool = { sideEffect(ignoreInput(printMama))($0 == 1) }
        let fa: (Int) -> Bool = { $0 == 1 } • (sideEffect § ignoreInput § printMama)

        scope("condition with 2 function calls") {
            func condition<Result>(_ condition: Bool, `if` ifFunction: () -> Result, `else` elseFunction: () -> Result) -> Result {
                return condition ? ifFunction() : elseFunction()
            }
        }
        
        scope("condition with 1 ugly function call") {
            func condition<Result>(_ condition: Bool, `if` ifFunction: () -> Result, `else` elseFunction: () -> Result) -> Result {
                return withoutActuallyEscaping(ifFunction) { ifFunction in
                    withoutActuallyEscaping(elseFunction) { elseFunction in
                       (condition ? ifFunction : elseFunction)()
                    }
                }
            }
        }
        
        scope("condition with prefix function call") {
            func condition<Result>(_ condition: Bool, `if` ifFunction: () -> Result, `else` elseFunction: () -> Result) -> Result {
                return withoutActuallyEscaping(ifFunction) { ifFunction in
                    withoutActuallyEscaping(elseFunction) { elseFunction in
                        () |> (condition ? ifFunction : elseFunction)
                    }
                }
            }
        }
        
        func call<Result>(_ action: () -> Result) -> Result {
            return action()
        }
        
        scope("call function") {
            let x: Int? = 1
            
            func print(_ value: String) {
                Swift.print(value)
            }
            
            scope("inline function call") {
                print § { x?.description ?? "empty" }()
            }
            
            scope("call function call") {
                print § call { x?.description ?? "empty" }
            }
        }
        
        func condition<Result>(_ value: Bool, `if` ifFunction: () -> Result, `else` elseFunction: () -> Result) -> Result {
            return withoutActuallyEscaping(ifFunction) { ifFunction in
                withoutActuallyEscaping(elseFunction) { elseFunction in
                    call § (value ? ifFunction : elseFunction)
                }
            }
        }
        
        scope("when with explicit nil") {
            // callIf -> Became when thx to Paul Taykalo
            func when<Result>(_ value: Bool, action: () -> Result) -> Result? {
                return condition(value, if: action, else: { nil })
            }
        }
        
        func equals<Value: Equatable>(_ lhs: Value) -> (Value) -> Bool {
            return { lhs == $0 }
        }
        
        scope("fEquals") {
            let fEquals: (Int) -> Bool = equals(1) • (sideEffect § ignoreInput § printMama)
            scope("map inefficient") {
                [1, 2]
                    .map(fEquals)
                    .map { "\($0)" }
                    .forEach { print($0) }
            }
            
            scope("map efficient, not reusable") {
                [1, 2]
                    .map(fEquals • { "\($0)" } )
                    .forEach { print($0) }
            }
            
            scope("map efficient, reusable") {
                func stringify<Value>(_ value: Value) -> String {
                    return "\(value)"
                }
                
                let transform = fEquals • stringify
                [1, 2]
                    .map(transform)
                    .forEach { print($0) }
            }
            
            scope("f similar to original code") {
                func printMamaSideEffect(when value: Bool) -> Bool {
                    return value |> sideEffect § { condition($0, if: printMama, else: returnValue § ()) }
                }
            }
        }
        
        func returnValue<Value>(_ value: Value) -> () -> Value {
            return { value }
        }
        
        func when<Result>(_ value: Bool, action: () -> Result?) -> Result? {
            return condition(value, if: action, else: returnValue § nil)
        }
        
        scope("useful as well") {
            func ignoreAndReturn<Value, Result>(_ result: Result) -> (Value) -> Result {
                return ignoreInput § returnValue § result
            }
            
            func unless<Result>(_ value: Bool, action: () -> Result) -> Result? {
                return when(!value, action: action)
            }
        }
        
        scope("uncurried") {
            func printMamaSideEffect(when value: Bool) -> Bool {
                return value |> sideEffect § { when($0, action: printMama) }
            }
        }
        
        func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
            return { a in
                { f(a, $0) }
            }
        }
        
        func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
            return { b in
                { f($0)(b) }
            }
        }
        
        func ignoreOutput<Value, Result>(_ f: @escaping (Value) -> Result) -> (Value) -> () {
            return { _ = f($0) }
        }
        
        let printMamaSideEffect = sideEffect § ignoreOutput § (when |> curry |> flip) § printMama
        
        let fEquals: (Int) -> Bool = equals(1) • printMamaSideEffect
        fEquals(1)
        fEquals(2)
        
        func greater<Value: Comparable>(_ lhs: Value) -> (Value) -> Bool {
            return { lhs > $0 }
        }
        
        let fGreater: (Int) -> Bool = (greater § 1) • printMamaSideEffect
        fGreater(0)
        fGreater(1)
        fGreater(2)
        
//        let less: (Int) -> (Int) -> Bool = (flip § greater)
        let fLess: (Int) -> Bool = (1 |> flip § greater) • printMamaSideEffect
        fLess(0)
        fLess(1)
        fLess(2)
    }
}

extension Optional {
    func `do`(_ action: (Wrapped) -> ()) {
        self.map(action)
    }
}

// ONLY FOR SYNC CALLS => @nonescaping
func extract<Value, Result>(_ outer: ((Value) -> ()) -> (), inner: (Value) -> Result) -> Result? {
    var result: Result?
    withoutActuallyEscaping(inner) { inner in
        outer { result = inner($0) }
    }
    
    return result
}

func extract<Result>(_ outer: (() -> ()) -> (), inner: () -> Result) -> Result? {
    var result: Result?
    withoutActuallyEscaping(inner) { inner in
        outer { result = inner() }
    }
    
    return result
}

scope("eDSL using trailing closures") {
    scope("extract") {
        func outerCall(_ action: () -> ()) {
            // do something before
            action()
            // do something after
        }
        
        scope("ugly") {
            var result: Int?
            outerCall { result = 1 }
            
            print(result ?? 0)
        }
        
        let result = extract(outerCall) { 1 }
        print(result ?? 0)
    }
    
    scope("adjust") {
        struct Value {
            var x: Int
        }
        
        let values = [1, 2].map(Value.init)
        
        scope("ugly") {
            let result: [Value] = values.map {
                var value = $0
                value.x += 1
                
                return value
            }
            
            result.forEach { print($0) }
        }
        
        func adjust<Value>(_ transform: @escaping (inout Value) -> ()) -> (Value) -> Value {
            return {
                var value = $0
                transform(&value)
                
                return value
            }
        }
        
        values
            .map(adjust { $0.x += 1 } )
            .forEach { print($0) }
    }
    
    scope("tuple") {
        let printInts: (Int, Int) -> () = {
            print("x1 = \($0), x2 = \($1)")
        }
        
        let x1: Int? = 1
        let x2: Int? = 2
        
        scope("ugly") {
            if
                let x1 = x1,
                let x2 = x2
            {
                printInts(x1, x2)
            }
        }
        
        func lift<A, B>(_ tuple: (A?, B?)) -> (A, B)? {
            return tuple.0.flatMap { a in
                tuple.1.map { (a, $0) }
            }
        }
        
        func lift<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
            return lift((a, b))
        }
        
        lift(x1, x2).do { x1, x2 in
            printInts(x1, x2)
        }
        
        lift(x1, x2).do(printInts)
    }
}

infix operator ~>: LeftCompositionPrecedence

typealias ExecuteFunction = () -> ()
typealias Function = (ExecuteFunction) -> ()

func ~> (_ lhs: @escaping Function, _ rhs: @escaping Function) -> Function {
    return { execute in lhs { rhs(execute) } }
}

scope("Namespaced eDSL") {
    
    struct Platform {
        static func mobile(_ execute: () -> ()) {
            #if (arch(arm) || arch(arm64))
                execute()
            #endif
        }

        static func mac(_ execute: () -> ()) {
            #if (arch(i386) || arch(x86_64))
                execute()
            #endif
        }
    }
    
    struct OS {
        static func iOS(_ execute: () -> ()) {
            #if os(iOS)
                execute()
            #endif
        }
        
        static func macOS(_ execute: () -> ()) {
            #if os(macOS)
                execute()
            #endif
        }
    }
    
    struct iOS {
        static let device = Platform.mobile ~> OS.iOS
        static let simulator = Platform.mac ~> OS.iOS
    }
    
    iOS.device { print("DO SOME METAL PROCESSING USING BLE") }
    iOS.simulator § printMama
}


protocol SumType: Equatable {
    static var current: Self { get }
    func `do`(_ transform: () -> ())
}

extension SumType {
    func `do`(_ transform: () -> ()) {
        if Self.current == self {
            transform()
        }
    }
}

func ~> <A: SumType, B: SumType>(_ lhs: A, _ rhs: B) -> Function {
    return { execute in
        lhs.do { rhs.do(execute) }
    }
}

func extract<Value: SumType, Result>(_ value: Value, inner: () -> Result) -> Result? {
    return extract(value.do, inner: inner)
}

scope("Namespaced Constrained eDSL") {

    enum Platform: SumType {
        case mobile
        case mac

        static var current: Platform {
            #if (arch(i386) || arch(x86_64))
                return .mac
            #endif

            #if (arch(arm) || arch(arm64))
                return .mobile
            #endif
        }

        static func `do`<Result>(mobile: () -> Result, mac: () -> Result) -> Result {
            switch self.current {
            case .mobile: return mobile()
            case .mac: return mac()
            }
        }
    }

    enum OS: SumType {
        case iOS
        case macOS

        static var current: OS {
            #if os(iOS)
                return .iOS
            #endif

            #if os(macOS)
                return .macOS
            #endif
        }

        static func `do`<Result>(iOS: () -> Result, macOS: () -> Result) -> Result {
            switch self.current {
            case .iOS: return iOS()
            case .macOS: return macOS()
            }
        }
    }

    enum iOS: SumType {
        case device
        case simulator
        case none
        
        static var current: iOS {
            switch (Platform.current, OS.current) {
            case (.mac, .iOS): return .simulator
            case (.mobile, .iOS): return .simulator
            default: return .none
            }
        }
        
        static func `do`<Result>(device: () -> Result, simulator: () -> Result, none: () -> Result) -> Result {
            switch self.current {
            case .device: return device()
            case .simulator: return simulator()
            case .none: return none()
            }
        }
    }
    
    iOS.do(
        device: { print("DO SOME METAL PROCESSING USING BLE") },
        simulator: printMama,
        none: { }
    )
    
    let deviceOne = extract(iOS.simulator) { 1 }
    print(deviceOne ?? -1)
    
    let simulatorOne = extract(Platform.mac ~> OS.iOS) { 1 }
    print(simulatorOne ?? -1)
}

struct DSL<Base> {
    let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}

protocol DSLProvider {
    var dsl: DSL<Self> { get }
}

extension DSLProvider {
    var dsl: DSL<Self> {
        return DSL(self)
    }
}

struct User: DSLProvider {
    var name = ""
}

extension DSL {
    func adjust(_ transform: @escaping (inout Base) -> ()) -> Base {
        var value = self.base
        transform(&value)
        
        return value
    }
}

extension DSL where Base == User {
    func renamed(to name: String) -> Base {
        return adjust { $0.name = name }
    }
}

scope("Holder DSL") {
    let user = User(name: "Vasia")
    
    print(user.dsl.renamed(to: "Ganzolder"))
}

scope("Declarative DSL - see IDPDesignable") { }
