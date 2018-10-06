//
//  ViewController.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import UIKit

open class ViewController<
    Model,
    ViewModel,
    Dependencies,
    View: Lib.View<Model, Dependencies, ViewModel>
>: UIViewController
    where
    Dependencies: ViewControllerDependencies,
    Dependencies.Model == Model,
    Dependencies.View == View
{
    
    // MARK: -
    // MARK: Properties
    
    public let model: Model
    public let dependencies: Dependencies
    
    // MARK: -
    // MARK: Init and Deinit
    
    public init(model: Model, dependencies: Dependencies) {
        self.model = model
        self.dependencies = dependencies
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    // MARK: View Lifecycle
    
    open override func loadView() {
        self.view = self.dependencies.view(withModel: self.model)
    }
    
    open override func viewDidLoad() {
       super.viewDidLoad()
        
       self.configure(withModel: self.model)
    }
    
    // MARK: -
    // MARK: Open
    
    open func configure(withModel: Model) {
        
    }
}

extension ViewController: RootViewRepresentable {
    public typealias RootView = View
}
