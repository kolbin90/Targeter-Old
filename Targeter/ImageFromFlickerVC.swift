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

    // MARK: - Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - LifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)  as! UICollectionViewCell
        // configureCell(cell, atIndexPath: indexPath)
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
