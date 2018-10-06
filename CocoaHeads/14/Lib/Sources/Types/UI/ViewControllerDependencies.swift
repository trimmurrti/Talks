//
//  ViewControllerDependencies.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import Foundation

public protocol ViewControllerDependencies {
    
    associatedtype Model
    associatedtype View
    
    func view(withModel: Model) -> View
}
