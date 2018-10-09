//
//  Operators.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

infix operator § : ApplicationPrecedence

infix operator • : CompositionPrecedence

infix operator §-> : CompactPrecedence
infix operator §∑-> : CompactPrecedence

prefix operator ∑->
