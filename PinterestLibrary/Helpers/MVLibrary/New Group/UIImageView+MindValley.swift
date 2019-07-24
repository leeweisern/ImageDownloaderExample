//
//  UIImageView+MindValley.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 24/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

protocol DownloadableImageView: class {
    var url: String { get set }
}

var IdentifiableIdKey   = "kIdentifiableIdKey"

extension UIImageView: DownloadableImageView {
    var url: String {
        get {
            return (objc_getAssociatedObject(self, &IdentifiableIdKey) as? String) ?? "default"
        }
        set {
            objc_setAssociatedObject(self, &IdentifiableIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension DownloadableImageView where Self: UIImageView {
    
    func setImage(withUrl url: Resource) {
        self.url = url.downloadURL.absoluteString
        image = nil
        
        MindValley.retrieveImage(with: url.downloadURL, completionHandler: strongify(weak: self) { (self, result) in
            switch result {
            case .success(let image):
                if self.url == url.downloadURL.absoluteString {
                    self.image = image
                }
                
            case .failure(let error):
                print("Download Image Error:", error)
            }
        })
    }
}
