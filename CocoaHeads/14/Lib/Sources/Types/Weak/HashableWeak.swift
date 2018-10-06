//
//  HashableWeak.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public struct HashableWeak<Wrapped: AnyObject & Hashable> {
    
    // MARK: -
    // MARK: Properties
    
    public var isEmpty: Bool {
        return self.wrapped == nil
    }
    
    public private(set) weak var wrapped: Wrapped?
    public let hashValue: Int
    
    // MARK: -
    // MARK: Init and Deinit
    
    public init(_ wrapped: Wrapped?) {
        self.wrapped = wrapped
        self.hashValue = wrapped?.hashValue ?? 0
    }
}

extension HashableWeak: Hashable {
    
    public static func == (lhs: HashableWeak, rhs: HashableWeak) -> Bool {
        return lhs.wrapped == rhs.wrapped
    }
}
