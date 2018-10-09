//
//  Function.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

enum F {
    
    static func pure<Value>(_ value: Value) -> () -> Value {
        return { value }
    }
}
