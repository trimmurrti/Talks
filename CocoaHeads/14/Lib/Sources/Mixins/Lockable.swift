//
//  Lockable.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

protocol Lockable: NSLocking { }

extension NSLock: Lockable { }
extension NSRecursiveLock: Lockable { }
