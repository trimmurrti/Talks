//
//  HashableTrait.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/20/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public struct HashableTrait<Value, Trait: Hashable>: Hashable {
    
    // MARK: -
    // MARK: Subtypes
    
    public enum F {
        public typealias Reader = (Value) -> Trait
    }
    
    // MARK: -
    // MARK: Properties
    
    public let value: Value
    public var trait: Trait {
        return self.reader(self.value)
    }
    
    private let reader: F.Reader
    
    
    // MARK: -
    // MARK: Init and Deinit
    
    public init(_ value: Value, reader: @escaping F.Reader) {
        self.value = value
        self.reader = reader
    }
    
    // MARK: -
    // MARK: Hashable
    
    public var hashValue: Int {
        return self.trait.hashValue
    }
    
    public static func == (lhs: HashableTrait, rhs: HashableTrait) -> Bool {
        return lhs.trait == rhs.trait
    }
}
