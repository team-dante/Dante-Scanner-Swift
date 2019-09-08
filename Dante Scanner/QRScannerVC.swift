//
//  QRScannerVC.swift
//  Dante Scanner
//
//  Created by Hung Phan on 8/21/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import Firebase

class QRScannerVC: UIViewController {
    
    // Set previewView to QRCodeReaderView class
    @IBOutlet weak var previewView: QRCodeReaderView! {
        didSet {
            previewView.setupComponents(with: QRCodeReaderViewControllerBuilder {
                $0.reader                 = reader
                $0.showTorchButton        = false
                $0.showSwitchCameraButton = false
                $0.showCancelButton       = false
                $0.showOverlayView        = true
                $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
            })
        }
    }
//     instiantiate QR reader object every time
    lazy var reader: QRCodeReader = QRCodeReader()
    var decodedString : String = ""
    var room : String = ""
    var role : Int = -1
    var greeting : String = ""
    var player : AVAudioPlayer?
    
    // when view appears, call scan
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.onScan()
    }
    
    func onScan() {
        
        guard checkScanPermissions() else { return }
        
        reader.didFindCode = { result in
            self.decodedString = result.value
            self.room = ChooseRoomViewController.GlobalVar.room
            print("room=", self.room, " decodedString=", self.decodedString)
            
            self.verifyRole { (verifySuccess) -> Void in
                if verifySuccess {
                    self.processData { (procSuccess) -> Void in
                        if procSuccess {
                            // insert audio here
                            print("??????????????????")
                            guard let url = Bundle.main.url(forResource: "iphoneAlert", withExtension: "mp3") else {
                                print("====>url not found")
                                return
                            }
                            do {
                                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                                try AVAudioSession.sharedInstance().setActive(true)
                                
                                self.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                                
                                guard let player = self.player else { return }
                                
                                player.play()
                                self.performSegue(withIdentifier: "MessageSegue", sender: nil)
                            } catch let error {
                                print("@@@@@@@@@", error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }

        reader.startScanning()
    }
    
    func verifyRole(completion: @escaping (_ verifySuccess: Bool) -> Void) {
        Database.database().reference().child("Staff").queryOrdered(byChild: "phoneNum").queryEqual(toValue: self.decodedString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                self.role = 0
            }
            else {
                self.role = 1
            }
            // halts immediately when complete
            completion(true)
        })
    }
    
    func processData(completion: @escaping (_ procSuccess: Bool) -> Void) {
        // update staff location (could have done a lot more)
        if self.role == 0 {
            Database.database().reference().child("/StaffLocation/\(self.decodedString)/room").setValue(self.room)
            self.greeting = "Hey, staff!\nYou are now at \(self.prettifyRoom(input: self.room))"
            completion(true)
        } // if it is a patient,
        else {
            // set up the path for modifying time tracking
            let child = Database.database().reference().child("/PatientVisitsByDates/\(self.decodedString)/\(self.formattedDate())")
            
            // set up the path for updating patient location
            let locationPath = Database.database().reference().child("/PatientLocation/\(self.decodedString)")
            
            child.observeSingleEvent(of: .value, with: {(snapshot) in
                if snapshot.exists() {
                    // assume the user is about to enter the current room
                    var inCurrRoom = true
                    
                    if let timeObjs = snapshot.value as? [String: Any] {
                        
                        // iterate through all time tracking objects for that patient at that particular day
                        for timeObj in timeObjs {
                            let uid = timeObj.key
                            
                            // if the time tracking object has inSession = true, set to false
                            // otherwise do nothing
                            if var obj = timeObj.value as? [String: Any] {
                                if let inSession = obj["inSession"] as? Bool {
                                    if inSession {
                                        child.child("/\(uid)/inSession").setValue(false)
                                        child.child("/\(uid)/endTime").setValue(Int(NSDate().timeIntervalSince1970))
                                        self.greeting = "Thank you for scanning out!\nYou left \(self.prettifyRoom(input: self.room))"
                                        
                                        // patient location will be set to "Private" when scanning out
                                        locationPath.setValue(["room": "Private"])
                                        
                                        // if the object that has inSession = true, and it's the current room,
                                        // it means the patient wanted to scan out; so do not push a new object
                                        if let currRoom = obj["room"] as? String {
                                            if currRoom == self.room {
                                                inCurrRoom = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // If patients are NOT in any of the rooms, scan them into the current room
                    if inCurrRoom {
                        child.childByAutoId().setValue(["room": self.room, "startTime": Int(NSDate().timeIntervalSince1970), "inSession": true, "endTime": 0])
                        locationPath.setValue(["room": self.room])
                        self.greeting = "Thank you for scanning in!\nYou are at \(self.prettifyRoom(input: self.room))"
                        
                        // halt the closure immediately once done
                        completion(true)
                    } else {
                        completion(true)
                    }
                } // if no snapshot, simply create a new time tracking object with inSession = true
                else {
                    child.childByAutoId().setValue(["room": self.room, "startTime": Int(NSDate().timeIntervalSince1970), "inSession": true, "endTime": 0])
                    self.greeting = "Thank you for scanning in!\nYou are at \(self.prettifyRoom(input: self.room))"
                    completion(true)
                }
            })
        }
    }
    
    // check if camera is allowed and valid
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let messageVC = segue.destination as! MessageViewController
        messageVC.message = self.greeting
    }

}
