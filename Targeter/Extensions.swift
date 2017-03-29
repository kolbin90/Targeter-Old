//
//  Extensions.swift
//  Targeter
//
//  Created by mac on 3/19/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit

extension UIViewController {

    
    // Show activity indicator
    func activityIndicatoryShowing(showing: Bool, view: UIView) {
        if showing {
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
            let container: UIView = UIView()
            let loadingView: UIView = UIView()
            container.tag = 10
            container.frame = view.frame
            container.center = view.center
            container.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.3)
            loadingView.frame = CGRect(x:0, y:0, width:80, height:80)
            loadingView.center = view.center
            loadingView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.7)
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 10
            activityIndicator.frame = CGRect(x:0, y:0, width:40, height:40)
            activityIndicator.center = CGPoint(x: (loadingView.frame.size.width / 2), y: (loadingView.frame.size.height / 2))
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            activityIndicator.color = UIColor(red: 1.000, green: 0.553, blue: 0.000, alpha: 1.0)
            DispatchQueue.main.async {
                loadingView.addSubview(activityIndicator)
                container.addSubview(loadingView)
                //view.addSubview(loadingView)
                view.addSubview(container)
                activityIndicator.startAnimating()
            }
        } else {
            let subViews = view.subviews
            for subview in subViews{
                if subview.tag == 10 {
                    DispatchQueue.main.async {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    // Show Alert controller with error
    func showAlert(title: String, error: String) {
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Keyboard Hide
    // Hide keyboard when tapped somewhere
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

