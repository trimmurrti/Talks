//
//  Atomic.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

class Atomic<Wrapped> {
    
    // MARK: -
    // MARK: Subtypes
    
    typealias Value = Wrapped
    typealias Observer = ((old: Value, new: Value)) -> ()
    
    // MARK: -
    // MARK: Static
    
    static func recursive(_ value: Value, observer: Observer? = nil)
        -> Atomic<Value>
    {
        return .init(value, lock: NSRecursiveLock(), observer: observer)
    }
    
    static func lock(_ value: Value, observer: Observer? = nil)
        -> Atomic<Value>
    {
        return .init(value, lock: NSLock(), observer: observer)
    }
    
    // MARK: -
    // MARK: Properties
    
    var value: Value {
        get { return self.transform { $0 } }
        set { self.modify { $0 = newValue } }
    }
    
    private let lock: Lockable
    private let observer: Observer?
    
    private var mutableValue: Value
    
    // MARK: -
    // MARK: Init and Deinit
    
    init(
        _ value: Value,
        lock: Lockable,
        observer: Observer? = nil
    ) {
        self.mutableValue = value
        self.lock = lock
        self.observer = observer
    }
    
    // MARK: -
    // MARK: Public
    
    func modify<Result>(
        _ action: (inout Value) -> Result
        )
        -> Result
    {
        return self.lock.do {
            let oldValue = self.mutableValue
            
            defer {
                self.observer?((oldValue, self.mutableValue))
            }
            
            return action(&self.mutableValue)
        }
    }
    
    func transform<Result>(
        _ action: (Value) -> Result
        )
        -> Result
    {
        return self.lock.do {
            action(self.mutableValue)
        }
    }
}
