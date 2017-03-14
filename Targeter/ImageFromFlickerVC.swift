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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // MARK: - LifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let space: CGFloat = 2.0
        let size = self.collectionView.frame.size
        let dimension:CGFloat = (size.width - (4 * space)) / 3.0
        let flowLayout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        collectionView.collectionViewLayout = flowLayout
    }
    
    // MARK: - Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let images = images else {
            return 0
        }
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)  as! ImageCell
        guard let images = images else {
            return cell
        }
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageView.image = images?[indexPath.row]
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
    
    @IBAction func searchButton(_ sender: Any) {
        
        if let text = textField.text, text != "" {
            FlickrClient.sharedInstance().getImagesFromFlickr(text: text) { (result, error) in
                guard (error == nil) else {
                    print("There was an error with the task for image")
                    return
                }
                guard let result = result else {
                    print("data error")
                    return
                }
                self.images = result
                self.collectionView.reloadData()
            }
        }
    }
    @IBAction func doneButton(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToAdd", sender: self)

    }
    

    
}
