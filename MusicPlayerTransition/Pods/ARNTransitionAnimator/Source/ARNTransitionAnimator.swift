//
//  TransitionAnimator.swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2016/07/02.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import UIKit

public enum TransitionType {
    case push
    case pop
    case present
    case dismiss
    
    public var isPresenting: Bool {
        return self == .push || self == .present
    }
    
    public var isDismissing: Bool {
        return self == .pop || self == .dismiss
    }
}

public final class ARNTransitionAnimator : NSObject {
    
    public let duration: TimeInterval
    public let animation: TransitionAnimatable
    
    fileprivate var interactiveTransitioning: InteractiveTransitioning?
    
    public init(duration: TimeInterval, animation: TransitionAnimatable) {
        self.duration = duration
        self.animation = animation
        
        super.init()
    }
    
    public func registerInteractiveTransitioning(_ transitionType: TransitionType, gestureHandler: TransitionGestureHandler) {
        let d = CGFloat(self.duration)
        let animator = TransitionAnimator(transitionType: transitionType, animation: animation)
        self.interactiveTransitioning = InteractiveTransitioning(duration: d, animator: animator, gestureHandler)
    }
    
    public func unregisgterInteractiveTransitioning() {
        self.interactiveTransitioning = nil
    }
}

extension ARNTransitionAnimator : UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = TransitionAnimator(transitionType: .present, animation: self.animation)
        return AnimatedTransitioning(animator: animator, duration: self.duration)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = TransitionAnimator(transitionType: .dismiss, animation: self.animation)
        return AnimatedTransitioning(animator: animator, duration: self.duration)
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let i = self.interactiveTransitioning , i.animator.transitionType.isPresenting else { return nil }
        if !i.gestureHandler.isTransitioning { return nil }
        return i
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let i = self.interactiveTransitioning , !i.animator.transitionType.isPresenting else { return nil }
        if !i.gestureHandler.isTransitioning { return nil }
        return i
    }
}

extension ARNTransitionAnimator: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return self.warappDelegate(navigationController, operation: operation, fromVC: fromVC, toVC: toVC)
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        return self.warappDelegate(navigationController, animationController: animationController)
    }
}

// MARK: - UINavigationControllerDelegate Wrapper

extension ARNTransitionAnimator {
    
    public func warappDelegate(_ navigationController: UINavigationController, operation: UINavigationController.Operation, fromVC: UIViewController, toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            let animator = TransitionAnimator(transitionType: .push, animation: self.animation)
            return AnimatedTransitioning(animator: animator, duration: self.duration)
        } else if operation == .pop {
            let animator = TransitionAnimator(transitionType: .pop, animation: self.animation)
            return AnimatedTransitioning(animator: animator, duration: self.duration)
        }
        
        return nil
    }
    
    public func warappDelegate(_ navigationController: UINavigationController, animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let i = self.interactiveTransitioning , !i.animator.transitionType.isPresenting else { return nil }
        if !i.gestureHandler.isTransitioning { return nil }
        return i
    }
}
