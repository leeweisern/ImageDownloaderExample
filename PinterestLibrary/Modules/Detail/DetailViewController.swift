//
//  DetailViewController.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 25/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var layoutView: DetailView { return view as! DetailView }
    
    public var didDismissView = Delegate<Void, Void>()
    
    private var imageUrl: URL?
    
    override func loadView() {
        view = DetailView()
    }
    
    init(imageURL: URL) {
        self.imageUrl = imageURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutView.imageView.setImage(withUrl: imageUrl!)
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    private func setupBindings() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnImage))
        layoutView.addGestureRecognizer(tap)
    }
    
    @objc
    private func didTapOnImage() {
        didDismissView.call()
    }
}
