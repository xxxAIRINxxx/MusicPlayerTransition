//
//  TransitionAnimatable.swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2016/07/25.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import UIKit

public protocol TransitionAnimatable : class {
    
    func sourceVC() -> UIViewController
    func destVC() -> UIViewController
    
    func prepareContainer(_ transitionType: TransitionType, containerView: UIView, from fromVC: UIViewController, to toVC: UIViewController)
    func willAnimation(_ transitionType: TransitionType, containerView: UIView)
    func animate(_ duration: TimeInterval, animations: @escaping (() -> Void), completion: ((Bool) -> Void)?)
    func updateAnimation(_ transitionType: TransitionType, percentComplete: CGFloat)
    func finishAnimation(_ transitionType: TransitionType, didComplete: Bool)
}

extension TransitionAnimatable {
    
    public func prepareContainer(_ transitionType: TransitionType, containerView: UIView, from fromVC: UIViewController, to toVC: UIViewController) {
        if transitionType.isPresenting {
            containerView.addSubview(fromVC.view)
            containerView.addSubview(toVC.view)
        } else {
            containerView.addSubview(toVC.view)
            containerView.addSubview(fromVC.view)
        }
        fromVC.view.setNeedsLayout()
        fromVC.view.layoutIfNeeded()
        toVC.view.setNeedsLayout()
        toVC.view.layoutIfNeeded()
    }
    
    public func animate(_ duration: TimeInterval, animations: @escaping (() -> Void), completion: ((Bool) -> Void)?) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: animations) { finished in
                        UIApplication.shared.endIgnoringInteractionEvents()
                        completion?(finished)
        }
    }
    
    /// examlpe of Key frame animation
    /*
    public func animate(_ duration: TimeInterval, animations: @escaping ((Void) -> Void), completion: ((Bool) -> Void)?) {
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: .beginFromCurrentState,
                                animations: animations,
                                completion: completion)
    }
     */
}
