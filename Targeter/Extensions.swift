//
//  Extensions.swift
//  Targeter
//
//  Created by mac on 3/19/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setNavigationController() {
        //navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.752, green: 0.876, blue: 1.0, alpha: 1.0)
            //.init(hue: 210, saturation: 0.250, brightness: 1, alpha: 1) //
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 22)!]
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 17)!], for: .normal)
        navigationController?.navigationBar.tintColor = .black
    }
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
            DispatchQueue.main.async {
                let subViews = view.subviews
                for subview in subViews {
                    if subview.tag == 10 {
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
} 

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in PNG format
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the PNG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    var png: Data? { return UIImagePNGRepresentation(self) }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
extension UIImage {
    func crop( rect: CGRect) -> UIImage {
        var rect1 = rect
        rect1.origin.x*=self.scale
        rect1.origin.y*=self.scale
        rect1.size.width*=self.scale
        rect1.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect1)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}

