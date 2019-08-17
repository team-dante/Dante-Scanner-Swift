//
//  extension.swift
//  Dante Scanner
//
//  Created by Hung Phan on 8/14/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

var vSpinner : UIView?
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

// DOESN'T WORK
//class CustomTextField : UITextField {
//    required init(coder aDecoder : NSCoder){
//        super.init(coder: aDecoder)!
//
//        self.layer.cornerRadius = 5.0
//
//    }
//}
//
//class CustomButton : UIButton {
//    required init(coder aDecoder : NSCoder){
//        super.init(coder: aDecoder)!
//
//        self.layer.cornerRadius = 10.0
//    }
//}
