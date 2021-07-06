let print: (String) -> () -> () = { string in
    { Swift.print(string) }
}

let f1 = print("f1")
let f2 = print("f2")
let f3 = print("f3")

func f(value: Int) {
    if value == 1 {
        f1()
    } else if value == 2 {
        f2()
    } else if value == 5 {
        f3()
    }
}

func solution(value: Int) {
    let rules = [
        1: f1,
        2: f2,
        5: f3
    ]

    rules[value]?()
}

solution(value: 5)
