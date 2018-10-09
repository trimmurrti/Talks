//
//  RootViewRepresentable.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import UIKit

public protocol RootViewRepresentable {
    
    associatedtype RootView
    
    var rootView: RootView? { get }
}

extension RootViewRepresentable where Self: UIViewController {
    
    public var rootView: RootView? {
        return self.viewIfLoaded.flatMap(cast)
    }
}
