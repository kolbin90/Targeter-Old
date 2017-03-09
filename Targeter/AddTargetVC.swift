//
//  AddTargetVC.swift
//  Targeter
//
//  Created by mac on 3/8/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit
import CoreData

class AddTargetVC: UIViewController {
    
    //MARK: - Variables
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    //MARK: - Outlets
    
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!

    
    
    //MARK: - Actions
    
    @IBAction func doneButton(_ sender: Any) {
        let date = Date()
        let newTarget = Target(title: titleTF.text!, descriptionCompletion: descriptionTF.text!, dayBeginning: date, dayEnding: date, picture: nil, active: true, completed: false, context: stack.context)
        print(newTarget)
        stack.save()
    }
}
