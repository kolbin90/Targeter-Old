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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController()
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
    
}
