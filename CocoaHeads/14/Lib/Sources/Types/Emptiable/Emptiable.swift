//
//  Emptiable.swift
//  Lib
//
//  Created by Oleksa 'trimm' Korin on 10/6/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

protocol Emptiable {
    
    static func materialize(_ value: Self?) -> Self
    static var `default`: Self { get }
    
    var isEmpty: Bool { get }
    var optional: Self? { get }
    
    var transformer: EmptyTransformer<Self> { get }
}

extension Emptiable {
    static func materialize(_ value: Self?) -> Self {
        return value ?? Self.default
    }
    
    var optional: Self? {
        return self.isEmpty ? nil : self
    }
    
    var transformer: EmptyTransformer<Self> {
        return .init(self)
    }
}

struct EmptyTransformer<T: Emptiable> {
    
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    func map<R>(_ ƒ: (T) -> R) -> EmptyTransformer<R> {
        return self.flatMap(ƒ)
    }
    
    func flatMap<R>(_ ƒ: (T) -> R?) -> EmptyTransformer<R> {
        return .init(.materialize(ƒ(self.value)))
    }
}
