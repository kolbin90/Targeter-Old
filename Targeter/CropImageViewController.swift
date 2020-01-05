//
//  CropImageViewController.swift
//  Targeter
//
//  Created by Apple User on 12/31/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit

class CropImageViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var image: UIImage?
    var imageView: UIImageView = UIImageView()
    var imageViewIsShown = false

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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func continueButton_TchUpIns(_ sender: Any) {
    }
    @IBAction func cancelButton_TchUpIns(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

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
