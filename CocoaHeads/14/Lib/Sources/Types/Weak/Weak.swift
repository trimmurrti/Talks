//
//  Weak.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public struct Weak<Wrapped: AnyObject> {
    
    // MARK: -
    // MARK: Properties
    
    public var isEmpty: Bool {
        return self.wrapped == nil
    }
    
    public private(set) weak var wrapped: Wrapped?
    
    // MARK: -
    // MARK: Init and Deinit
    
    public init(_ wrapped: Wrapped?) {
        self.wrapped = wrapped
    }
}

extension Weak: Equatable {
    
    public static func == (lhs: Weak, rhs: Weak) -> Bool {
        return Tuple.lift(lhs.wrapped, rhs.wrapped).map(===) ?? false
    }
}
