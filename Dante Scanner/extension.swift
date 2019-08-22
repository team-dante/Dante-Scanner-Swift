//
//  extension.swift
//  Dante Scanner
//
//  Created by Hung Phan on 8/14/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import Foundation

var vSpinner : UIView?
extension UIViewController {
    
    // return today's date in YYYY-MM-DD format
    func formattedDate() -> String {
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let day = calendar.component(.day, from: today)
        let formattedMonth = month < 10 ? "0\(month)" : "\(month)"
        let formattedDay = day < 10 ? "0\(day)" : "\(day)"
        return "\(year)-\(formattedMonth)-\(formattedDay)"
    }
    
    func prettifyRoom(input : String) -> String {
        switch input {
        case "WR":
            return "Waiting Room"
        case "CT":
            return "CT Simulator"
        case "LA1":
            return "Linear Accelerator 1"
        case  "TLA":
            return "Trilogy Linear Accelerator"
        default:
            return "N/A"
        }
    }
    
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
