//
//  Optional+Apply.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public extension Optional {
    
    public func apply<Result>(_ ƒ: ((Wrapped) -> Result)?) -> Result? {
        return ƒ.apply(self)
    }
    
    public func apply<Value, Result>(_ value: Value?) -> Result?
        where Wrapped == (Value) -> Result
    {
        return self.flatMap { value.map($0) }
    }
}

public func § <Value, Result>(function: ((Value) -> Result)?, value: Value?) -> Result? {
    return function.apply(value)
}
