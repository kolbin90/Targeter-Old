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
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        setScrollView()
        // Do any additional setup after loading the view.
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
        imageView.contentMode = .center
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.width)
        imageView.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        
        scrollView.contentSize = image.size
        
        let scaleWidth = scrollView.frame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollView.frame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth,scaleHeight)
        let maxScale = max(scaleWidth,scaleHeight)
        
        scrollView.minimumZoomScale = maxScale
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = maxScale
        scrollView.addSubview(imageView)

        //centerScrollViewContent()
      
    }
    
    func centerScrollViewContent() {
        let boundsSize = scrollView.bounds.size
        var contentFrame = imageView.frame
        
        if contentFrame.width < boundsSize.width {
            contentFrame.origin.x = (boundsSize.width - contentFrame.width) / 2
        } else {
            contentFrame.origin.x = 0
        }
        
        if contentFrame.height < boundsSize.height {
            contentFrame.origin.y = (boundsSize.height - contentFrame.height) / 2
        } else {
            contentFrame.origin.y = 0
        }
        
        imageView.frame = contentFrame
    }
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //centerScrollViewContent()
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
