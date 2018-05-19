//
//  ImageFromFlickerVC.swift
//  Targeter
//
//  Created by mac on 3/13/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit
import CoreData

class ImageFromFlickerVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var insertedIndexPaths = [IndexPath]()
    var deletedIndexPaths = [IndexPath]()
    var updatedIndexPaths = [IndexPath]()
    var imageSearch:ImageSearch!
    var fetchedResultsController: NSFetchedResultsController<Image>!
    var itemCount = 0 // to resolve bug. Read more: https://fangpenlin.com/posts/2016/04/29/uicollectionview-invalid-number-of-items-crash-issue/

    
    // MARK: - Outlets
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // MARK: - Init/Deinit
    
    deinit {
        stack.context.delete(imageSearch)
        stack.save()
    }
    // MARK: - LifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        imageSearch = ImageSearch.init(searchTitle: nil, context: stack.context)
        fetchedResultsController = {
            let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
            let predicate = NSPredicate.init(format: "imageSearch == %@", argumentArray: [imageSearch])
            let sortDescriptor = NSSortDescriptor(key: "imageSearch", ascending: false)
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [sortDescriptor]
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
            frc.delegate = self
            return frc
        }()
        do {
            try fetchedResultsController.performFetch()
        }
        catch let error as NSError {
            print("An error occured \(error) \(error.userInfo)")
        }
        
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
    // MARK: TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    // MARK: Controller Delegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
            
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            if self.collectionView.numberOfSections == 0 {
                self.collectionView.reloadData()
            } else {
                if self.updatedIndexPaths.count == 0 {
                   self.itemCount = self.itemCount + self.insertedIndexPaths.count - self.deletedIndexPaths.count
                }
                self.collectionView.performBatchUpdates(
                    {
                        () -> Void in
                        for indexPath in self.insertedIndexPaths {
                            self.collectionView.insertItems(at: [indexPath])
                            // self.itemCount! += 1
                        }
                        for indexPath in self.deletedIndexPaths {
                            self.collectionView.deleteItems(at: [indexPath])
                            //self.itemCount! -= 1
                        }
                        for indexPath in self.updatedIndexPaths {
                            self.collectionView.reloadItems(at: [indexPath])
                        }
                }
                    ,completion: nil)
                
                self.insertedIndexPaths = [IndexPath]()
                self.deletedIndexPaths = [IndexPath]()
                self.updatedIndexPaths = [IndexPath]()
            }
        }
    }
    
    // MARK: CollectionView delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)  as! ImageCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let imageData = fetchedResultsController.object(at: indexPath).imageData {
                imageView.image = UIImage(data: imageData)
        } else {
            showAlert(title: "Error", error: "Image is not downloaded yet")
        }
    }
    
    
    // MARK: - Assist functions
    func configureCell(_ cell: ImageCell, atIndexPath indexPath: IndexPath) {
        let image = fetchedResultsController.object(at: indexPath)
        cell.imageView?.image = nil
        if let imageData = image.imageData {
            cell.imageView!.image = UIImage(data: imageData)
        } else {
            cell.imageView!.image = #imageLiteral(resourceName: "placeholder")
        }
    }

    
    // MARK: - Actions
    
    @IBAction func searchButton(_ sender: Any) {
        if let text = textField.text, text != "" {
            activityIndicatoryShowing(showing: true, view: backView)
            DispatchQueue.main.async {
                 if let imagesForDelition = self.imageSearch.images {
                    //let imagesForDelition = self.imageSearch.images
                    let arrayOfImages = Array(imagesForDelition)
                        for image in arrayOfImages {
                            self.stack.context.delete(image as! NSManagedObject)
                        }
                }
                // Getting images URLs and creating objects with image url
                FlickrClient.sharedInstance.getImagesFromFlickr(imageSearch: self.imageSearch, text: text) { (result, error) in
                    self.activityIndicatoryShowing(showing: false, view: self.backView)
                    self.view.reloadInputViews()
                    guard (error == nil) else {
                        self.showAlert(title: "Error", error: error!)
                        return
                    }
                    guard (result != nil) else {
                        self.showAlert(title: "Error", error: "Data error")
                        return
                    }
                    DispatchQueue.main.async {
                        // Getting data for image URLs
                        FlickrClient.sharedInstance.getImagesDataFor(imageSearch: self.imageSearch)
                    }
                }
            }
        } else {
            print("textfield is empty")
        }
    }
    
    @IBAction func doneButton(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToAdd", sender: self)
        
    }
    
    
    
}
