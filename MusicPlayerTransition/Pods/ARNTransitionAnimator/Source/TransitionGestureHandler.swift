//
//  TransitionGestureHandler.swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2016/08/25.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

public enum DirectionType {
    case top
    case bottom
    case left
    case right
}

public enum TransitionState {
    case start
    case update(percentComplete: CGFloat)
    case finish
    case cancel
}

public final class TransitionGestureHandler : NSObject {
    
    public let direction: DirectionType
    
    public var updateGestureHandler: ((TransitionState) -> Void)?
    
    public var panStartThreshold: CGFloat = 10.0
    public var panCompletionThreshold: CGFloat = 30.0
    public var velocityThreshold: CGFloat = 0.0
    public var panBoundsPoint: CGPoint?
    public var panFrameSize: CGSize?
    
    fileprivate let targetView: UIView
    
    fileprivate(set) var isTransitioning: Bool = false
    fileprivate(set) var percentComplete: CGFloat = 0.0
    
    fileprivate var panLocationStart: CGFloat = 0.0
    fileprivate var gesture: UIPanGestureRecognizer?
    
    deinit {
        self.unregisterGesture()
    }
    
    public init(targetVC: UIViewController, direction: DirectionType) {
        self.targetView = targetVC.view
        self.direction = direction
        
        super.init()
        
        self.registerGesture(self.targetView)
    }
    
    
    public init(targetView: UIView, direction: DirectionType) {
        self.targetView = targetView
        self.direction = direction
        
        super.init()
        
        self.registerGesture(self.targetView)
    }
    
    private func registerGesture(_ view: UIView) {
        self.gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        self.gesture?.maximumNumberOfTouches = 1
        self.gesture?.delegate = self
        view.addGestureRecognizer(self.gesture!)
    }
    
    public func unregisterGesture() {
        guard let g = self.gesture else { return }
        g.view?.removeGestureRecognizer(g)
        self.gesture = nil
    }
    
    private func resetValues() {
        self.isTransitioning = false
        self.percentComplete = 0.0
        self.panLocationStart = 0.0
    }
    
    @objc fileprivate func handleGesture(_ recognizer: UIPanGestureRecognizer) {
        let window = self.targetView.window
        
        var location = recognizer.location(in: window)
        location = location.applying(recognizer.view!.transform.inverted())
        
        self.updatePercentComplete(location)
        
        switch recognizer.state {
        case .began:
            self.resetValues()
            if self.isNeedSetPanStartLocation() {
                self.setPanStartPoint(location)
            }
        case .changed:
            if self.isNeedSetPanStartLocation() {
                self.startTransitionIfNeeded(location)
            } else {
                if self.isTransitioning {
                    self.updateGestureHandler?(.update(percentComplete: self.percentComplete))
                    self.forceCancelIfNeeded(location)
                }
            }
        case .ended:
            if !self.isTransitioning { return }
            
            var velocity = recognizer.velocity(in: window)
            velocity = velocity.applying(recognizer.view!.transform.inverted())
            
            var velocityForSelectedDirection: CGFloat = 0.0
            switch self.direction {
            case .top:
                velocityForSelectedDirection = velocity.y * -1.0
            case .bottom:
                velocityForSelectedDirection = velocity.y
            case .left:
                velocityForSelectedDirection = velocity.x * -1.0
            case .right:
                velocityForSelectedDirection = velocity.x
            }
            
            if velocityForSelectedDirection > self.velocityThreshold && (self.percentComplete * 100) > self.panCompletionThreshold {
                self.updateGestureHandler?(.finish)
            } else {
                self.updateGestureHandler?(.cancel)
            }
        case .cancelled:
            if !self.isTransitioning { return }
            self.updateGestureHandler?(.cancel)
        default:
            if !self.isTransitioning { return }
            self.updateGestureHandler?(.cancel)
        }
    }
    
    fileprivate func isNeedSetPanStartLocation() -> Bool {
        if self.isTransitioning { return false }
        
        if let scrollView = self.targetView as? UIScrollView {
            if scrollView.contentOffset.y <= 0 && scrollView.isTracking {
                return true
            }
            if scrollView.contentSize.height < scrollView.frame.size.height {
                return true
            }
        } else {
            return true
        }
        return false
    }
    
    fileprivate func setPanStartPoint(_ location: CGPoint) {
        switch self.direction {
        case .top:
            self.panLocationStart = location.y
        case .bottom:
            if self.targetView is UIScrollView {
                self.panLocationStart = location.y
            } else {
                self.panLocationStart = location.y
            }
        case .left, .right:
            self.panLocationStart = location.x
        }
    }
    
    fileprivate func forceCancelIfNeeded(_ location: CGPoint) {
        if !self.isTransitioning { return }
        guard self.targetView is UIScrollView else { return }
        if self.percentComplete >= 0 { return }
        
        self.percentComplete = 1.0
        self.updateGestureHandler?(.cancel)
        self.unregisterGesture()
        self.registerGesture(self.targetView)
    }
    
    fileprivate func updatePercentComplete(_ location: CGPoint) {
        var bounds: CGFloat = 0.0
        if let boundsPoint = panBoundsPoint {
            switch self.direction {
            case .top, .bottom:
                bounds = abs(boundsPoint.y - panLocationStart)
            case .left, .right:
                bounds = abs(boundsPoint.x - panLocationStart)
            }
        } else {
            switch self.direction {
            case .top, .bottom:
                bounds = self.panFrameSize != nil ? self.panFrameSize!.height : self.targetView.bounds.height
            case .left, .right:
                bounds = self.panFrameSize != nil ? self.panFrameSize!.width : self.targetView.bounds.width
            }
        }
        switch self.direction {
        case .top:
            self.percentComplete = min((self.panLocationStart - location.y) / bounds, 1)
        case .bottom:
            self.percentComplete = min((location.y - self.panLocationStart) / bounds, 1)
        case .left:
            self.percentComplete = min((self.panLocationStart - location.x) / bounds, 1)
        case .right:
            self.percentComplete = min((location.x - self.panLocationStart) / bounds, 1)
        }
    }
    
    fileprivate func startTransitionIfNeeded(_ location: CGPoint) {
        if self.isTransitioning { return }
        
        switch self.direction {
        case .top:
            if (self.panLocationStart - location.y) < self.panStartThreshold { return }
        case .bottom:
            if (location.y - self.panLocationStart) < self.panStartThreshold { return }
        case .left:
            if (self.panLocationStart - location.x) < self.panStartThreshold { return }
        case .right:
            if (location.x - self.panLocationStart) < self.panStartThreshold { return }
        }
        self.isTransitioning = true
        self.updateGestureHandler?(.start)
        self.setPanStartPoint(location)
        self.updatePercentComplete(location)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension TransitionGestureHandler : UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let g = self.gesture else { return false }
        guard g.view is UIScrollView else { return false }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
