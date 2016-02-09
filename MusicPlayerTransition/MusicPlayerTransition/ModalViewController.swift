//
//  ModalViewController.swift
//  SoundCloudTransition
//
//  Created by xxxAIRINxxx on 2015/02/25.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    
    var tapCloseButtonActionHandler : (Void -> Void)?
    var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup Blur Effect
        self.view.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: .Dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        self.view.insertSubview(blurView, atIndex: 0)
        
        addVibrantLabelForBlurEffect(blurEffect)
    }
    
    @IBAction func blurSegmentChanged(sender: UISegmentedControl) {
        addBlurEffectWithStyleNumber(sender.selectedSegmentIndex)
    }
    
    func addBlurEffectWithStyleNumber(blurStyle: Int) {
        blurView.removeFromSuperview()
        var blurEffect: UIBlurEffect
        
        switch blurStyle {
        case 0:
            blurEffect = UIBlurEffect(style: .Dark)
        case 1:
            blurEffect = UIBlurEffect(style: .Light)
        case 2:
            blurEffect = UIBlurEffect(style: .ExtraLight)
        default:
            blurEffect = UIBlurEffect(style: .Dark)
        }
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        self.view.insertSubview(blurView, atIndex: 0)
        
        addVibrantLabelForBlurEffect(blurEffect)
    }
    
    func addVibrantLabelForBlurEffect(blurEffect: UIBlurEffect) {
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = self.view.bounds
        blurView.contentView.addSubview(vibrancyView)
        
        let testLabel = UILabel(frame: view.frame)
        testLabel.text = "Blurry!!"
        testLabel.font = UIFont.boldSystemFontOfSize(44)
        testLabel.textAlignment = .Center
        vibrancyView.contentView.addSubview(testLabel)
    }
    
    @IBAction func tapCloseButton() {
        self.tapCloseButtonActionHandler?()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("ModalViewController viewWillAppear")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("ModalViewController viewWillDisappear")
    }
}
