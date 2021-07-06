import Foundation

func measure(f: () -> ()) {
    let start = Date()

    f()
    
    let time = Date().timeIntervalSince(start)
    print("duration = \(floor(time / 60))m \(time.truncatingRemainder(dividingBy: 60))s ")
}




let numbers = ["papa"] + [String](repeating: "1", count: 100000) + ["mama"]

func f(strings: [String]) -> Int {
  strings.reduce(0) { $0 + (Int($1) ?? 0) }
}

func solution(strings: [String]) -> Int {
    var result = 0
    
    let concurrentCount = 10
    
    let group = DispatchGroup()
    let size = strings.count / concurrentCount
    let count = strings.count
    
    let sumQueue = DispatchQueue(label: "sum", qos: .default)
    
    let chunks = stride(from: 0, to: count, by: size).map {
        $0..<min($0 + size, count)
    }
    
    for chunk in chunks {
        group.enter()
        
        DispatchQueue.global(qos: .default).async {
            let chunkResult = strings[chunk].reduce(0) { $0 + (Int($1) ?? 0) }
            sumQueue.sync { result += chunkResult }
            group.leave()
        }
    }
    
    group.wait()

    return result
}

measure { print(f(strings: numbers)) }
measure { print(solution(strings: numbers)) }
