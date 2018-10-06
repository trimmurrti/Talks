//
//  ViewModel.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

open class ViewModel<Model> {
    
    // MARK: -
    // MARK: Subtypes
    
    public typealias Callback = () -> ()
    
    // MARK: -
    // MARK: Properties
    
    public var didChange: Callback?
}
