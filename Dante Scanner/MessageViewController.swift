//
//  MessageViewController.swift
//  Dante Scanner
//
//  Created by Hung Phan on 8/21/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    var message : String = ""
    var counter : Int = 5
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageLabel.text = message
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "QRScannerVC") as! QRScannerVC
            self.present(VC, animated: true, completion: nil)
        }
    }
    @objc func update() {
        if counter > 0 {
            counter -= 1
            counterLabel.text = String(counter)
        }
    }
}
