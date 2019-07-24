//
//  View.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 20/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

class View: UIView {
    
    public let collectionViewSideInsets: CGFloat = 4
    public let collectionViewColumns = 2
    public let collectionViewCellPadding: CGFloat = 4
    
    public var collectionViewCellWidth: CGFloat {
        let paddings = CGFloat(collectionViewColumns) * collectionViewCellPadding
        let insets = collectionViewSideInsets
        let width = UIScreen.main.bounds.width / CGFloat(2) - paddings - insets
        
        return width
    }
    
    public let loader = UIRefreshControl()
    
    @IBOutlet public var collectionView: UICollectionView! {
        didSet {
            collectionView.refreshControl = loader
            collectionView.contentInset = UIEdgeInsets(top: 0,
                                                       left: collectionViewSideInsets,
                                                       bottom: 0,
                                                       right: collectionViewSideInsets)
            let layout = PinterestLayout(cellPadding: collectionViewCellPadding,
                                         numberOfColumns: collectionViewColumns)
            collectionView.setCollectionViewLayout(layout, animated: false)
            collectionView.register(ImageCell.nib(),
                                    forCellWithReuseIdentifier: ImageCell.cellReuseIdentifier())
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }
    
    func customInit() {
        self.fromNib()
    }
}
