//
//  UIViewController+Extensions.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 24/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(withText alertText: String = "MindValley" , alertMessage : String) {
        let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
