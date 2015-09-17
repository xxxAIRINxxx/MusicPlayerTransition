//
//  ARNTransitionAnimator.swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2015/02/26.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

public enum ARNTransitionAnimatorDirection: Int {
    case Top
    case Bottom
    case Left
    case Right
}

public enum ARNTransitionAnimatorOperation: Int {
    case None
    case Push
    case Pop
    case Present
    case Dismiss
}

public class ARNTransitionAnimator: UIPercentDrivenInteractiveTransition {
    
    // animation setting
    
    public var usingSpringWithDamping : CGFloat = 1.0
    public var transitionDuration : NSTimeInterval = 0.5
    public var initialSpringVelocity : CGFloat = 0.1
    
    // interactive gesture
    
    public weak var gestureTargetView : UIView? {
        willSet {
            self.unregisterPanGesture()
        }
        didSet {
            self.registerPanGesture()
        }
    }
    public var panCompletionThreshold : CGFloat = 100.0
    public var direction : ARNTransitionAnimatorDirection = .Bottom
    public var contentScrollView : UIScrollView? {
        didSet {
            if let _contentScrollView = self.contentScrollView {
                self.tmpBounces = _contentScrollView.bounces
            }
        }
    }
    public var interactiveType : ARNTransitionAnimatorOperation = .None {
        didSet {
            if self.interactiveType == .None {
                self.unregisterPanGesture()
            } else {
                self.registerPanGesture()
            }
        }
    }
    
    // handlers
    
    public var presentationBeforeHandler : ((containerView: UIView, transitionContext: UIViewControllerContextTransitioning) ->())?
    public var presentationAnimationHandler : ((containerView: UIView, percentComplete: CGFloat) ->())?
    public var presentationCancelAnimationHandler : ((containerView: UIView) ->())?
    public var presentationCompletionHandler : ((containerView: UIView, completeTransition: Bool) ->())?
    
    public var dismissalBeforeHandler : ((containerView: UIView, transitionContext: UIViewControllerContextTransitioning) ->())?
    public var dismissalAnimationHandler : ((containerView: UIView, percentComplete: CGFloat) ->())?
    public var dismissalCancelAnimationHandler : ((containerView: UIView) ->())?
    public var dismissalCompletionHandler : ((containerView: UIView, completeTransition: Bool) ->())?
    
    // private
    
    private weak var fromVC : UIViewController!
    private weak var toVC : UIViewController!
    
    private(set) var operationType : ARNTransitionAnimatorOperation
    private(set) var isPresenting : Bool = true
    private(set)  var isTransitioning : Bool = false
    
    private var gesture : UIPanGestureRecognizer?
    private var transitionContext : UIViewControllerContextTransitioning?
    private var panLocationStart : CGFloat = 0.0
    private var tmpBounces: Bool = true
    
    deinit {
        self.unregisterPanGesture()
    }
    
    // MARK: Constructor
    
    public init(operationType: ARNTransitionAnimatorOperation, fromVC: UIViewController, toVC: UIViewController) {
        self.operationType = operationType
        self.fromVC = fromVC
        self.toVC = toVC
        
        switch (self.operationType) {
        case .Push, .Present:
            self.isPresenting = true
        case .Pop, .Dismiss:
            self.isPresenting = false
        case .None:
            break
        }
    }
    
    // MARK: Private Methods
    
    private func registerPanGesture() {
        self.unregisterPanGesture()
        
        self.gesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
        self.gesture!.delegate = self
        self.gesture!.maximumNumberOfTouches = 1
        
        if let _gestureTargetView = self.gestureTargetView {
            _gestureTargetView.addGestureRecognizer(self.gesture!)
        } else {
            switch (self.interactiveType) {
            case .Push, .Present:
                self.fromVC.view.addGestureRecognizer(self.gesture!)
            case .Pop, .Dismiss:
                self.toVC.view.addGestureRecognizer(self.gesture!)
            case .None:
                break
            }
        }
    }
    
    private func unregisterPanGesture() {
        if let _gesture = self.gesture {
            if let _view = _gesture.view {
                _view.removeGestureRecognizer(_gesture)
            }
            _gesture.delegate = nil
        }
        self.gesture = nil
    }
    
    private func fireBeforeHandler(containerView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            self.presentationBeforeHandler?(containerView: containerView, transitionContext: transitionContext)
        } else {
            self.dismissalBeforeHandler?(containerView: containerView, transitionContext: transitionContext)
        }
    }
    
    private func fireAnimationHandler(containerView: UIView, percentComplete: CGFloat) {
        if self.isPresenting {
            self.presentationAnimationHandler?(containerView: containerView, percentComplete: percentComplete)
        } else {
            self.dismissalAnimationHandler?(containerView: containerView, percentComplete: percentComplete)
        }
    }

    private func fireCancelAnimationHandler(containerView: UIView) {
        if self.isPresenting {
            self.presentationCancelAnimationHandler?(containerView: containerView)
        } else {
            self.dismissalCancelAnimationHandler?(containerView: containerView)
        }
    }
    
    private func fireCompletionHandler(containerView: UIView, completeTransition: Bool) {
        if self.isPresenting {
            self.presentationCompletionHandler?(containerView: containerView, completeTransition: completeTransition)
        } else {
            self.dismissalCompletionHandler?(containerView: containerView, completeTransition: completeTransition)
        }
    }
    
    private func animateWithDuration(duration: NSTimeInterval, containerView: UIView, completeTransition: Bool, completion: (() -> Void)?) {
        UIView.animateWithDuration(
            duration,
            delay: 0,
            usingSpringWithDamping: self.usingSpringWithDamping,
            initialSpringVelocity: self.initialSpringVelocity,
            options: .CurveEaseOut,
            animations: {
                if completeTransition {
                    self.fireAnimationHandler(containerView, percentComplete: 1.0)
                } else {
                    self.fireCancelAnimationHandler(containerView)
                }
            }, completion: { finished in
                self.fireCompletionHandler(containerView, completeTransition: completeTransition)
                completion?()
        })
    }
    
    // MARK: Gesture
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        var window : UIWindow? = nil
        
        switch (self.interactiveType) {
        case .Push, .Present:
            window = self.fromVC.view.window
        case .Pop, .Dismiss:
            window = self.toVC.view.window
        case .None:
            return
        }
        
        var location = recognizer.locationInView(window)
        location = CGPointApplyAffineTransform(location, CGAffineTransformInvert(recognizer.view!.transform))
        var velocity = recognizer .velocityInView(window)
        velocity = CGPointApplyAffineTransform(velocity, CGAffineTransformInvert(recognizer.view!.transform))
        
        if recognizer.state == .Began {
            switch (self.direction) {
            case .Top, .Bottom:
                self.panLocationStart = location.y
            case .Left, .Right:
                self.panLocationStart = location.x
            }
            
            if let _contentScrollView = self.contentScrollView {
                if _contentScrollView.contentOffset.y <= 0.0 {
                    self.startGestureTransition()
                    _contentScrollView.bounces = false
                }
            } else {
                self.startGestureTransition()
            }
        } else if recognizer.state == .Changed {
            var bounds = CGRectZero
            switch (self.interactiveType) {
            case .Push, .Present:
                bounds = self.fromVC.view.bounds
            case .Pop, .Dismiss:
                bounds = self.toVC.view.bounds
            case .None:
                break
            }
            
            var animationRatio: CGFloat = 0.0
            switch self.direction {
            case .Top:
                animationRatio = (self.panLocationStart - location.y) / CGRectGetHeight(bounds)
            case .Bottom:
                animationRatio = (location.y - self.panLocationStart) / CGRectGetHeight(bounds)
            case .Left:
                animationRatio = (self.panLocationStart - location.x) / CGRectGetWidth(bounds)
            case .Right:
                animationRatio = (location.x - self.panLocationStart) / CGRectGetWidth(bounds)
            }
            
            if let _contentScrollView = self.contentScrollView {
                if self.isTransitioning == false && _contentScrollView.contentOffset.y <= 0 {
                    self.startGestureTransition()
                    self.contentScrollView!.bounces = false
                } else {
                    self.updateInteractiveTransition(animationRatio)
                }
            } else {
                self.updateInteractiveTransition(animationRatio)
            }
        } else if recognizer.state == .Ended {
            var velocityForSelectedDirection: CGFloat = 0.0
            switch (self.direction) {
            case .Top, .Bottom:
                velocityForSelectedDirection = velocity.y
            case .Left, .Right:
                velocityForSelectedDirection = velocity.x
            }
            
            if velocityForSelectedDirection > self.panCompletionThreshold && (self.direction == .Right || self.direction == .Bottom) {
                self.finishInteractiveTransition()
            } else if velocityForSelectedDirection < -self.panCompletionThreshold && (self.direction == .Left || self.direction == .Top) {
                self.finishInteractiveTransition()
            } else {
                self.cancelInteractiveTransition()
            }
            self.resetGestureTransitionSetting()
        } else {
            self.resetGestureTransitionSetting()
            self.cancelInteractiveTransition()
        }
    }
    
    func startGestureTransition() {
        if self.isTransitioning == false {
            self.isTransitioning = true
            switch (self.interactiveType) {
            case .Push:
                self.fromVC.navigationController?.pushViewController(self.toVC, animated: true)
            case .Present:
                self.fromVC.presentViewController(self.toVC, animated: true, completion: nil)
            case .Pop:
                self.toVC.navigationController?.popViewControllerAnimated(true)
            case .Dismiss:
                self.toVC.dismissViewControllerAnimated(true, completion: nil)
            case .None:
                break
            }
        }
    }
    
    func resetGestureTransitionSetting() {
        self.isTransitioning = false
        if let _contentScrollView = self.contentScrollView {
            _contentScrollView.bounces = self.tmpBounces
        }
    }
}

// MARK: UIViewControllerAnimatedTransitioning

extension ARNTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.transitionDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        
        self.transitionContext = transitionContext
        self.fireBeforeHandler(containerView!, transitionContext: transitionContext)
        
        self.animateWithDuration(
            self.transitionDuration(transitionContext),
            containerView: containerView!,
            completeTransition: true) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    public func animationEnded(transitionCompleted: Bool) {
        self.transitionContext = nil
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension ARNTransitionAnimator: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
        return self
    }
    
    public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if self.gesture != nil && (self.interactiveType == .Push || self.interactiveType == .Present) {
            self.isPresenting = true
            return self
        }
        return nil
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if self.gesture != nil && (self.interactiveType == .Pop || self.interactiveType == .Dismiss) {
            self.isPresenting = false
            return self
        }
        return nil
    }
}

// MARK: UIViewControllerInteractiveTransitioning

extension ARNTransitionAnimator {
    
    public override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        
        // FIXME : UINavigationController not called animator UIViewControllerTransitioningDelegate
        switch (self.interactiveType) {
        case .Push, .Present:
            self.isPresenting = true
        case .Pop, .Dismiss:
            self.isPresenting = false
        case .None:
            break
        }
        
        self.transitionContext = transitionContext
        self.fireBeforeHandler(containerView!, transitionContext: transitionContext)
    }
}

// MARK: UIPercentDrivenInteractiveTransition

extension ARNTransitionAnimator {
    
    public override func updateInteractiveTransition(percentComplete: CGFloat) {
        super.updateInteractiveTransition(percentComplete)
        if let transitionContext = self.transitionContext {
            let containerView = transitionContext.containerView()
            self.fireAnimationHandler(containerView!, percentComplete: percentComplete)
        }
    }
    
    public override func finishInteractiveTransition() {
        super.finishInteractiveTransition()
        if let transitionContext = self.transitionContext {
            let containerView = transitionContext.containerView()
            self.animateWithDuration(
                self.transitionDuration(transitionContext),
                containerView: containerView!,
                completeTransition: true) {
                    transitionContext.completeTransition(true)
            }
        }
    }
    
    public override func cancelInteractiveTransition() {
        super.cancelInteractiveTransition()
        if let transitionContext = self.transitionContext {
            let containerView = transitionContext.containerView()
            self.animateWithDuration(
                self.transitionDuration(transitionContext),
                containerView: containerView!,
                completeTransition: false) {
                    transitionContext.completeTransition(false)
            }
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension ARNTransitionAnimator: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.contentScrollView != nil ? true : false
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
