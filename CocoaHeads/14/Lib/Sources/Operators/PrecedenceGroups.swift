//
//  PrecedenceGroups.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

precedencegroup ApplicationPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

precedencegroup CompositionPrecedence {
    higherThan: ApplicationPrecedence
    associativity: left
}

precedencegroup CompactPrecedence {
    higherThan: CompositionPrecedence
}
