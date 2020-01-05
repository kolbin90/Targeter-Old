//
//  TestViewController.swift
//  Targeter
//
//  Created by Apple User on 1/5/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        //let x = 0
        let image = #imageLiteral(resourceName: "zakat")
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        imageView.contentMode = .center
        imageView.image = image
        
        scrollView.contentSize.width = scrollView.frame.size.width * 3
        scrollView.contentSize.height = scrollView.frame.size.height * 3

        scrollView.addSubview(imageView)
        // Do any additional setup after loading the view.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
