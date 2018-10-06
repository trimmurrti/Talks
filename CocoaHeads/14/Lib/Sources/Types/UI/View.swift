//
//  View.swift
//  TicTacToe
//
//  Created by Oleksa 'trimm' Korin on 7/19/18.
//  Copyright © 2018 Oleksa 'trimm' Korin. All rights reserved.
//

import UIKit

open class View<Model, Dependencies: ViewDependencies, ViewModel: Lib.ViewModel<Model>>: UIView {
    
    // MARK: -
    // MARK: Properties
    
    public let model: ViewModel
    public let dependencies: Dependencies
    
    open var contentSubviews: [UIView] {
        return []
    }
    
    // MARK: -
    // MARK: Init and Deinit
    
    public init(model: ViewModel, dependencies: Dependencies) {
        self.model = model
        self.dependencies = dependencies
        
        super.init(frame: .zero)
        
        self.configure()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init() {
        fatalError("init() has not been implemented")
    }
    
    // MARK: -
    // MARK: Open

    open func configure() {
        self.bind()
        self.configureContentSubviews()
    }
    
    open func fill(withModel: ViewModel) {
        
    }
    
    open func bind() {
        // TODO: TRY IT FOR INHERITANCE CLAUSE
//        viewModel.didChange = weakify(self, ƒ: View.fill §-> viewModel)
        
        let model = self.model
        model.didChange = { [weak self] in
            self?.fill § model
        }
    }
    
    open func configureContentSubviews() {
        self.contentSubviews.apply • void § [
            self.addSubview,
            { $0.translatesAutoresizingMaskIntoConstraints = false }
        ]
    }
}
