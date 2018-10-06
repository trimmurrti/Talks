//
//  Observer.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public class Observer<Target: AnyObject> {
    
    // MARK: -
    // MARK: Subtypes
    
    public typealias WeakTarget = HashableWeak<HashableIdentityAnyObject<Target>>
    public typealias Callback = (Target) -> Void
    
    // MARK: -
    // MARK: Properties
    
    public var target: Target? {
        return self.weakTarget.wrapped?.value
    }
    
    private var weakTarget: WeakTarget
    private let callback: Callback
    public private(set) var isDisposed = false
    
    // MARK: -
    // MARK: Init and Deinit
    
    public init(target: Target, callback: @escaping Callback) {
        self.weakTarget = WeakTarget.init § .init(value: target)
        self.callback = callback
    }
    
    // MARK: -
    // MARK: Public
    
    public func dispose() {
        self.weakTarget = .init(nil)
        self.isDisposed = true
    }
}

extension Observer: Hashable {
    
    public var hashValue: Int {
        return self.weakTarget.hashValue
    }
    
    public static func == (lhs: Observer, rhs: Observer) -> Bool {
        return lhs.weakTarget == rhs.weakTarget
    }
}
