//
//  PopAnimator.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 25/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

public class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    public let duration = 0.8
    public var presenting = true
    public var originFrame = CGRect.zero
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            presentVC(using: transitionContext)
        } else {
            dismissVC(using: transitionContext)
        }
    }
    
    private func presentVC(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let view = transitionContext.view(forKey: .to) else { return }
        
        let initialFrame = originFrame
        let finalFrame = view.frame
        
        let xScaleFactor = initialFrame.width / finalFrame.width
        
        let yScaleFactor = initialFrame.height / finalFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)

        if presenting {
            view.transform = scaleTransform
            view.center = CGPoint(
                x: initialFrame.midX,
                y: initialFrame.midY)
            view.clipsToBounds = true
        }
        
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true

        containerView.addSubview(view)
        containerView.bringSubviewToFront(view)
        
        UIView.animate(
            withDuration: duration,
            delay:0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.2,
            animations: {
                view.transform = .identity
                view.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                view.layer.cornerRadius = 0.0
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })

    }
    
    private func dismissVC(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let view = transitionContext.view(forKey: .from) else { return }
        
        let initialFrame = view.frame
        let finalFrame = originFrame
        
        let xScaleFactor = finalFrame.width / initialFrame.width
        
        let yScaleFactor = finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        view.layer.cornerRadius = 0
        view.layer.masksToBounds = true
        
        containerView.addSubview(view)
        containerView.bringSubviewToFront(view)
        
        UIView.animate(
            withDuration: duration,
            delay:0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.2,
            animations: {
                view.transform = scaleTransform
                view.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                view.layer.cornerRadius = 20.0
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}
