//
//  ChooseRoomViewController.swift
//  Dante Scanner
//
//  Created by Hung Phan on 8/17/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import Firebase

class ChooseRoomViewController: UIViewController {

    @IBOutlet weak var room1: UIButton!
    @IBOutlet weak var room2: UIButton!
    @IBOutlet weak var room3: UIButton!
    struct GlobalVar {
        static var room = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        room1.layer.cornerRadius = 10
        room2.layer.cornerRadius = 10
        room3.layer.cornerRadius = 10
    }
    
    @IBAction func room1(_ sender: Any) {
        self.performSegue(withIdentifier: "qrScannerPreview", sender: nil)
        GlobalVar.room = "WR"
    }
    @IBAction func room2(_ sender: Any) {
        self.performSegue(withIdentifier: "qrScannerPreview", sender: nil)
        GlobalVar.room = "CTS"
    }
    @IBAction func room3(_ sender: Any) {
        self.performSegue(withIdentifier: "qrScannerPreview", sender: nil)
        GlobalVar.room = "LA2"
    }
    
}
