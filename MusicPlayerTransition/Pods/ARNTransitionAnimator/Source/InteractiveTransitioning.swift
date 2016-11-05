//
//  InteractiveAnimator.swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2016/07/26.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation

final class InteractiveTransitioning : UIPercentDrivenInteractiveTransition {
    
    let animator: TransitionAnimator
    let gestureHandler: TransitionGestureHandler
    let transitionDuration: CGFloat
    
    fileprivate var transitionContext: UIViewControllerContextTransitioning?
    
    init(duration: CGFloat, animator: TransitionAnimator, _ gestureHandler: TransitionGestureHandler) {
        self.transitionDuration = duration
        self.animator = animator
        self.gestureHandler = gestureHandler
        
        super.init()
        
        self.handleGesture()
    }
    
    fileprivate func handleGesture() {
        self.gestureHandler.updateGestureHandler = { [weak self] state in
            switch state {
            case .start:
                self?.startTransition()
            case .update(let percentComplete):
                self?.update(percentComplete)
            case .finish:
                self?.finish()
            case .cancel:
                self?.cancel()
            }
        }
    }
    
    fileprivate func completeTransition(_ didComplete: Bool) {
        self.transitionContext?.completeTransition(didComplete)
        self.transitionContext = nil
    }
    
    fileprivate func startTransition() {
        switch self.animator.transitionType {
        case .push:
            self.animator.fromVC.navigationController?.pushViewController(self.animator.toVC, animated: true)
        case .present:
            self.animator.fromVC.present(self.animator.toVC, animated: true, completion: nil)
        case .pop:
            _ = self.animator.fromVC.navigationController?.popViewController(animated: true)
        case .dismiss:
            self.animator.fromVC.dismiss(animated: true, completion: nil)
        }
    }
}

extension InteractiveTransitioning {
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.animator.willAnimation(transitionContext.containerView)
    }
    
    override func update(_ percentComplete: CGFloat) {
        super.update(percentComplete)
        
        self.animator.updateAnimation(percentComplete)
    }
    
    override func finish() {
        super.finish()
        
        let d = self.transitionDuration - (self.transitionDuration * self.percentComplete)
        
        self.animator.animate(TimeInterval(d), animations: { [weak self] in self?.animator.updateAnimation(1.0) }) { [weak self] finished in
            self?.animator.finishAnimation(true)
            self?.completeTransition(true)
        }
    }
    
    override func cancel() {
        super.cancel()
        
        let d = self.transitionDuration * (1.0 - self.percentComplete)
        
        self.animator.animate(TimeInterval(d), animations: { [weak self] in self?.animator.updateAnimation(0.0) }) { [weak self] finished in
            self?.animator.finishAnimation(false)
            self?.completeTransition(false)
        }
    }
}
