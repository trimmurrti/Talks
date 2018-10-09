//
//  Sequence+Extensions.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public extension Sequence {
    
    public func array() -> [Element] {
        return self.map(identity)
    }
}

public extension Sequence where Element: Hashable {
    
    public func set() -> Set<Element> {
        return Set(self)
    }
    
    public func uniqueArray() -> [Element] {
        return self.set().array()
    }
}

public extension Sequence where SubSequence: Sequence {
    
    public typealias Neighbours = (
        current: SubSequence.Element,
        previous: Element
    )
    
    public func neighbourElements() -> [Neighbours] {
        return zip(self.dropFirst(), self).array()
    }
}
