//
//  DetailView.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 25/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

class DetailView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }
    
    let imageView = UIImageView()
    
    func customInit() {
        self.backgroundColor = .clear
        self.addSubview(imageView)
        
//        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layoutAttachAll()
    }
}
