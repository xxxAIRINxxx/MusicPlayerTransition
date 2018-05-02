//
//  TransitionAnimator.swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2016/07/25.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import UIKit

final class TransitionAnimator {
    
    let transitionType: TransitionType
    let animation: TransitionAnimatable
    
    init(transitionType: TransitionType, animation: TransitionAnimatable) {
        self.transitionType = transitionType
        self.animation = animation
    }
    
    func willAnimation(_ containerView: UIView) {
        self.animation.prepareContainer(self.transitionType, containerView: containerView, from: self.fromVC, to: self.toVC)
        self.animation.willAnimation(self.transitionType, containerView: containerView)
    }
    
    func animate(_ duration: TimeInterval, animations: @escaping (() -> Void), completion: ((Bool) -> Void)?) {
        self.animation.animate(duration, animations: animations, completion: completion)
    }
    
    func updateAnimation(_ percentComplete: CGFloat) {
        self.animation.updateAnimation(self.transitionType, percentComplete: percentComplete)
    }
    
    func finishAnimation(_ didComplete: Bool) {
        if didComplete {
            if !self.transitionType.isPresenting {
                self.fromVC.view.removeFromSuperview()
            }
        } else {
            if self.transitionType.isPresenting {
                self.toVC.view.removeFromSuperview()
            }
        }
        self.animation.finishAnimation(self.transitionType, didComplete: didComplete)
    }
}

extension TransitionAnimator {
    
    var fromVC: UIViewController {
        return self.transitionType.isPresenting ? self.animation.sourceVC() : self.animation.destVC()
    }
    
    var toVC: UIViewController {
        return self.transitionType.isPresenting ? self.animation.destVC() : self.animation.sourceVC()
    }
}
