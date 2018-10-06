//
//  Array+Extensions.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public extension Array {
//    
//    public func apply<Value, Result>(_ value: Value) -> [Result]
//        where Element == (Value) -> Result
//    {
//        return [value].apply(self)
//    }
//    
    public func apply<Value, Result>(_ values: [Value]) -> [Result]
        where Element == (Value) -> Result
    {
        return self.flatMap { values.map($0) }
    }
    
    public func apply<Result>(_ ƒs: [(Element) -> Result]) -> [Result] {
        return ƒs.apply(self)
    }
}

public func § <Value, Result>(functions: [(Value) -> Result], value: Value) -> [Result] {
    return functions § [value]
}

public func § <Value, Result>(functions: [(Value) -> Result], value: [Value]) -> [Result] {
    return functions.apply(value)
}
