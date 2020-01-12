//
//  CropImageViewController.swift
//  Targeter
//
//  Created by Apple User on 12/31/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit

protocol CropImageViewControllerDelegate {
    func setImage(_ image: UIImage)
    
}

class CropImageViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    // MARK: Variables
    var delegate: CropImageViewControllerDelegate?
    var image: UIImage?
    var imageView: UIImageView = UIImageView()
    var imageViewIsShown = false

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController()

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        if !imageViewIsShown {
            setScrollView()
        }
    }
    
    
    // MARK: Assist methods

    func cropImage(completion: @escaping () -> Void) {
        UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.main.scale)

        let renderer = UIGraphicsImageRenderer(size: scrollView.frame.size)
        let image = renderer.image { ctx in
            scrollView.drawHierarchy(in: scrollView.frame, afterScreenUpdates: true)
        }
        delegate?.setImage(image)
        completion()

    }
    // MARK: Actions
    @IBAction func continueButton_TchUpIns(_ sender: Any) {
        cropImage() {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelButton_TchUpIns(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
// MARK: - Extensions
// MARK: UIScrollViewDelegate
extension CropImageViewController: UIScrollViewDelegate {
    
    func setScrollView() {
        scrollView.delegate = self
        guard let image = image else {
            return
        }
        imageView.image = image
        imageView.contentMode = .top
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.width)

        imageView.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        
        scrollView.contentSize.height = image.size.height
        scrollView.contentSize.width = image.size.width
        
        let scaleWidth = scrollView.frame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollView.frame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth,scaleHeight)
        let maxScale = max(scaleWidth,scaleHeight)
        
        scrollView.minimumZoomScale = maxScale
        scrollView.maximumZoomScale = 2
        scrollView.zoomScale = maxScale
        scrollView.addSubview(imageView)
        imageViewIsShown = true

        
        
        centerScrollViewContent()
      
    }
    
    func centerScrollViewContent() {
        if #available(iOS 11.0, *) {
            imageView.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor)
            imageView.centerYAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerYAnchor)
        } else {
            let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
        }
    }
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContent()
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
