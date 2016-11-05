//
//  AnimatedTransitioning .swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2016/07/25.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation

final class AnimatedTransitioning : NSObject {
    
    let animator: TransitionAnimator
    let duration: TimeInterval
    
    init(animator: TransitionAnimator, duration: TimeInterval) {
        self.animator = animator
        self.duration = duration
        
        super.init()
    }
}

extension AnimatedTransitioning : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.animator.willAnimation(transitionContext.containerView)
        
        self.animator.animate(self.duration, animations: { [weak self] in self?.animator.updateAnimation(1.0) }) { [weak self] finished in
            self?.animator.finishAnimation(true)
            transitionContext.completeTransition(true)
        }
    }
}

