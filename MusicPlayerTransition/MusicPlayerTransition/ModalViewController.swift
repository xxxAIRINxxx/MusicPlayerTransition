//
//  ModalViewController.swift
//  MusicPlayerTransition
//
//  Created by xxxAIRINxxx on 2015/02/25.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    
    @IBOutlet weak var imageView : UIImageView!
    
    var tapCloseButtonActionHandler : (Void -> Void)?
    
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
