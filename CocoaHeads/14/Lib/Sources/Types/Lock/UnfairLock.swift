//
//  UnfairLock.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/20/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public class UnfairLock: Lockable {
    
    // MARK: -
    // MARK: Properties
    
    private let unfairLock: os_unfair_lock_t
    
    // MARK: -
    // MARK: Init and Deinit
    
    deinit {
        let lock = self.unfairLock
        
        lock.deinitialize(count: 1)
        lock.deallocate(capacity: 1)
    }
    
    public init() {
        let lock = os_unfair_lock_t.allocate(capacity: 1)
        lock.initialize(to: os_unfair_lock())
        
        self.unfairLock = lock
    }
    
    // MARK: -
    // MARK: Lockable
    
    public func lock() {
        os_unfair_lock_lock(self.unfairLock)
    }
    
    public func unlock() {
        os_unfair_lock_unlock(self.unfairLock)
    }
}
