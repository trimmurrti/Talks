//
//  Application.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public func scope(execute function: () -> ()) {
    function()
}

public func call<Result>(execute function: () -> Result) -> Result {
    return function()
}

public func § <Value, Result>(function: (Value) -> Result, value: Value) -> Result {
    return function(value)
}
