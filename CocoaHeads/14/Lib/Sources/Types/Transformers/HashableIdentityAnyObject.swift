//
//  HashableIdentityAnyObject.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public class HashableIdentityAnyObject<Value: AnyObject>: Hashable {
    
    // MARK: -
    // MARK: Properties
    
    public private(set) var value: Value
    
    // MARK: -
    // MARK: Init and Deinit
    
    public init(value: Value) {
        self.value = value
    }
    
    // MARK: -
    // MARK: Hashable
    
    public var hashValue: Int {
        return ObjectIdentifier(self.value).hashValue
    }
    
    public static func == (lhs: HashableIdentityAnyObject, rhs: HashableIdentityAnyObject) -> Bool {
        return lhs.value === rhs.value
    }
}
