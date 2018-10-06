//
//  Weakify.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public func weakify<Value: AnyObject, Arguments, Result>(
    _ object: Value,
    default value: Result,
    ƒ: @escaping (Value) -> (Arguments) -> Result
)
    -> (Arguments) -> Result
{
    return { [weak object] arguments in
        object.map { ƒ § $0 § arguments } ?? value
    }
}

public func weakify<Value: AnyObject, Arguments>(
    _ object: Value,
    ƒ: @escaping (Value) -> (Arguments) -> ()
)
    -> (Arguments) -> ()
{
    return weakify(object, default: (), ƒ: ƒ)
}

// TODO: SPECIALIZATION BELOW IS NECESSARY BECAUSE OF FAULTY SWIFT TYPE INFERENCE, CHECK IN FUTURE SWIFT VERSIONS

public func weakify<Value: AnyObject, Result>(
    _ object: Value,
    default value: Result,
    ƒ: @escaping (Value) -> () -> Result
)
    -> () -> Result
{
    return { [weak object] in
        object.map { ƒ § $0 § () } ?? value
    }
}

public func weakify<Value: AnyObject>(
    _ object: Value,
    ƒ: @escaping (Value) -> () -> ()
)
    -> () -> ()
{
    return weakify(object, default: (), ƒ: ƒ)
}
