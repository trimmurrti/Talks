//
//  Array+Flatten.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

extension Array {

    public func flatten<Result>() -> [Result]
        where Element == [Result]
    {
        return self.joined().array()
    }
}
