//
//  PinterestLayoutDelegate.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 21/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}
