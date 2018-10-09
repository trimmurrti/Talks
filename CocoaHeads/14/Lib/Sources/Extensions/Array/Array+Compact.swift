//
//  Array+Compact.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public extension Array {
    
    public func compact<Result>() -> [Result]
        where Element == Result?
    {
        return self.compactMap(identity)
    }
}
