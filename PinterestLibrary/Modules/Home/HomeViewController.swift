//
//  ViewController.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 20/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var controller = Controller()
    
    var layoutView: HomeView { return view as! HomeView }
    
    override func loadView() {
        view = HomeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        setupBindings()
        controller.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    private func configureCollectionView() {
        if let layout = layoutView.collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        
        layoutView.collectionView.dataSource = self
        layoutView.collectionView.delegate = self
    }
    
    private func setupBindings() {
        layoutView.loader.addTarget(self,
                                    action: #selector(pulledToRefresh(_:)),
                                    for: .valueChanged)
        
        controller.didLoadData.delegate(on: self) { (self, _) in
            self.stopLoadingAnimation()
            self.layoutView.collectionView.reloadData()
            self.layoutView.collectionView.collectionViewLayout.invalidateLayout()
        }
        
        controller.didLoadMoreData.delegate(on: self) { (self, _) in
            self.stopLoadingAnimation()
            self.layoutView.collectionView.reloadData()
        }
        
        controller.errorLoading.delegate(on: self) { (self, error) in
            self.stopLoadingAnimation()
        }
        
    }
    
    private func stopLoadingAnimation() {
        if layoutView.loader.isRefreshing {
            layoutView.loader.endRefreshing()
        }
    }
    
    @objc
    private func pulledToRefresh(_ sender: UIRefreshControl) {
        controller.reloadData()
    }
}

//MARK: -> UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return controller.data.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 9 {
            
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellReuseIdentifier(), for: indexPath) as? ImageCell else { fatalError() }
        
        cell.updateCell(with: controller.data[indexPath.item])
        
        return cell
    }
}

//MARK: -> PinterestLayoutDelegate
extension ViewController: PinterestLayoutDelegate {
    internal func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        print("Index: ", indexPath.item)
        if indexPath.item == 9 {
            
        }
        let model = controller.data[indexPath.item]
        let cellHeight = Double(layoutView.collectionViewCellWidth) / model.width * model.height
        return CGFloat(cellHeight)
    }
}

//MARK: -> UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == controller.data.count - 1 {
            self.controller.loadMoreData()
        }
    }
}


