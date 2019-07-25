//
//  ImageCell.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 20/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit
import MVImageDownloader

class ImageCell: UICollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 5
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            
        }
    }
    
    public func updateCell(with model: DataModel) {
        guard let url = URL(string: model.urls.regular) else { return }
        
        imageView.image = nil
        imageView.setImage(withUrl: url)
    }
}


