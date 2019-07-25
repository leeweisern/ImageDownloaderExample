//
//  ViewController.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 20/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    var controller = HomeController()
    
    var layoutView: HomeView { return view as! HomeView }
    
    private let transition = PopAnimator()

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
            self.showAlert(alertMessage: error.message)
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
extension HomeViewController: UICollectionViewDataSource {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return controller.data.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellReuseIdentifier(), for: indexPath) as? ImageCell else { fatalError() }
        
        cell.updateCell(with: controller.data[indexPath.item])
        
        return cell
    }
}

//MARK: -> PinterestLayoutDelegate
extension HomeViewController: PinterestLayoutDelegate {
    internal func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let model = controller.data[indexPath.item]
        let cellHeight = Double(layoutView.collectionViewCellWidth) / model.width * model.height
        return CGFloat(cellHeight)
    }
}

//MARK: -> UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == controller.data.count - 1 {
            self.controller.loadMoreData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = controller.data[indexPath.item]
        let vc = DetailViewController(imageURL: URL(string: model.urls.regular)!)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.transitioningDelegate = self
        navVC.modalPresentationStyle = .overCurrentContext
        
        vc.didDismissView.delegate(on: self) { (self, _) in
            self.dismiss(animated: true, completion: nil)
        }
        
        present(navVC, animated: true)
    }
}

//MARK: -> UIViewControllerTransitioningDelegate
extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController, source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            guard let selectedIndexPathCell = layoutView.collectionView.indexPathsForSelectedItems?.first,
                let selectedCell = layoutView.collectionView.cellForItem(at: selectedIndexPathCell)
                    as? ImageCell,
                let selectedCellSuperview = selectedCell.superview
                else {
                    return nil
            }
            
            transition.originFrame = selectedCellSuperview.convert(selectedCell.frame, to: nil)
            transition.originFrame = CGRect(
                x: transition.originFrame.origin.x,
                y: transition.originFrame.origin.y,
                width: transition.originFrame.size.width,
                height: transition.originFrame.size.height
            )
            
            transition.presenting = true
            return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false

        return transition
    }
}
