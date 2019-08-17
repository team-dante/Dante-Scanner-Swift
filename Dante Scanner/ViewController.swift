//
//  ViewController.swift
//  Dante Scanner
//
//  Created by Hung Phan on 8/13/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    var handle : AuthStateDidChangeListenerHandle?

    @IBOutlet weak var passcodeTextField: CustomTextField!
    @IBOutlet weak var accessBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passcodeTextField.layer.cornerRadius = 10
        accessBtn.layer.cornerRadius = 10
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user != nil) {
                print("USER IS STILL LOGGED IN ==>", String((user?.email!)!))
            }
            else {
                print("USER IS NOT LOGGED IN")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    @IBAction func accessBtnPressed(_ sender: Any) {
        self.showSpinner(onView: self.view)
        let text: String = passcodeTextField.text!
        let email = text + "@email.com"
        let password = text
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            guard let strongSelf = self else { return }
            strongSelf.removeSpinner()
            if error != nil {
                strongSelf.passcodeTextField.text = ""
                let alert = UIAlertController(title: "Error", message: "Invalid credentials", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                strongSelf.present(alert, animated: true)
                return
            }
            strongSelf.passcodeTextField.text = ""
            strongSelf.performSegue(withIdentifier: "gotoQRscanner", sender: strongSelf)
        }
    }
    
}

