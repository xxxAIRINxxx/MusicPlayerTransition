//
//  ViewController.swift
//  MusicPlayerTransition
//
//  Created by xxxAIRINxxx on 2015/08/27.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

final class ViewController: UIViewController {
    
    @IBOutlet fileprivate(set) weak var containerView : UIView!
    @IBOutlet fileprivate(set) weak var tabBar : UITabBar!
    @IBOutlet fileprivate(set) weak var miniPlayerView : LineView!
    @IBOutlet fileprivate(set) weak var miniPlayerButton : UIButton!
    
    private var animator : ARNTransitionAnimator?
    fileprivate var modalVC : ModalViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.modalVC = storyboard.instantiateViewController(withIdentifier: "ModalViewController") as? ModalViewController
        self.modalVC.modalPresentationStyle = .overCurrentContext
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.3)
        self.miniPlayerButton.setBackgroundImage(self.generateImageWithColor(color), for: .highlighted)
        
        self.setupAnimator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("ViewController viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("ViewController viewWillDisappear")
    }
    
    func setupAnimator() {
        let animation = MusicPlayerTransitionAnimation(rootVC: self, modalVC: self.modalVC)
        animation.completion = { [weak self] isPresenting in
            if isPresenting {
                guard let _self = self else { return }
                let modalGestureHandler = TransitionGestureHandler(targetView: _self.modalVC.view, direction: .bottom)
                modalGestureHandler.panCompletionThreshold = 15.0
                _self.animator?.registerInteractiveTransitioning(.dismiss, gestureHandler: modalGestureHandler)
            } else {
                self?.setupAnimator()
            }
        }
        
        let gestureHandler = TransitionGestureHandler(targetView: self.miniPlayerView, direction: .top)
        gestureHandler.panCompletionThreshold = 15.0
        gestureHandler.panFrameSize = self.view.bounds.size

        self.animator = ARNTransitionAnimator(duration: 0.5, animation: animation)
        self.animator?.registerInteractiveTransitioning(.present, gestureHandler: gestureHandler)
        
        self.modalVC.transitioningDelegate = self.animator
    }
    
    @IBAction func tapMiniPlayerButton() {
        self.present(self.modalVC, animated: true, completion: nil)
    }
    
    fileprivate func generateImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

