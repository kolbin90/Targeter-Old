//
//  ImageFromFlickerVC.swift
//  Targeter
//
//  Created by mac on 3/13/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit

class ImageFromFlickerVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    // MARK: - Properties
    var images: [UIImage]?
    // MARK: - Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - LifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        FlickrClient.sharedInstance().getImagesFromFlickr(text: "vodnik") { (result, error) in
            print(result!)
        }
    }
    
    // MARK: - Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let images = images else {
            return 0
        }
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)  as! UICollectionViewCell
        guard let images = images else {
            return cell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }

    
    // MARK: - Assist functions
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    // MARK: - Actions
    
    
}
