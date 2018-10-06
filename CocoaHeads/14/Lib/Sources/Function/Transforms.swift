//
//  Transforms.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public func cast<Value, Result>(_ value: Value) -> Result? {
    return value as? Result
}

public func identity<Value>(_ value: Value) -> Value {
    return value
}

public func typeString<T>(_ type: T.Type) -> String {
    return String(describing: type)
}

public func typeString<T>(_ value: T) -> String {
    return typeString(type(of: value))
}

public func void<Value>(_ value: Value) { }

public func • <A, B, C>(
    lhs: @escaping (A) -> B,
    rhs: @escaping (B) -> C
)
    -> (A) -> C
{
    return { rhs(lhs § $0) }
}

public prefix func ∑-> <Type, Result>(_ function: @escaping (Type) -> () -> Result) -> (Type) -> Result {
    return { function § $0 § () }
}

public func §-> <Type, Arguments, Result>(
    _ function: @escaping (Type) -> (Arguments) -> Result,
    arguments: Arguments
)
    -> (Type) -> () -> Result
{
    return { type in
        { function § type § arguments }
    }
}

public func §∑-> <Type, Arguments, Result>(
    _ function: @escaping (Type) -> (Arguments) -> Result,
    arguments: Arguments
)
    -> (Type) -> Result
{
    return ∑->(function §-> arguments)
}

