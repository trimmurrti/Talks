//
//  Tuple+Type.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/20/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public extension Tuple {
    
    public static func lift<A, B>(_ tuple: (A?, B?)) -> (A, B)? {
        return tuple.0.flatMap { lhs in
            tuple.1.flatMap { (lhs, $0) }
        }
    }
    
    public static func lift<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
        return lift((a, b))
    }
    
    public static func duplicate<A>(_ value: A) -> (A, A) {
        return (value, value)
    }
}

