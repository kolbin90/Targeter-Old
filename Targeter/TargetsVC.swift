//
//  TargetsVC.swift
//  Targeter
//
//  Created by mac on 3/8/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit
import CoreData
//import FSCalendar
import UserNotifications
import Firebase
import FirebaseUI
import GoogleSignIn


// MARK: - CoreDataTableViewController: UITableViewController

class TargetsVC: UITableViewController {
    // MARK: Outlets
    @IBOutlet weak var loginButton: UIBarButtonItem!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    // MARK: Properties
    let dateFormatter = DateFormatter()
    var userID: String?
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    var targets:[AnyObject] = []
    
    fileprivate var _refHandle: DatabaseHandle!
    let imageCache = (UIApplication.shared.delegate as! AppDelegate).imageCache
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle! // Listens when Firebase Auth changed status
    var user: User?
    var displayName = "Anonymous"  // name before user logged in
    
        // Colors for check ins
    let greenColor = UIColor.init(red: 46/256, green: 184/256, blue: 46/256, alpha: 1)
    let redColor = UIColor(red: 0.872, green: 0.255, blue: 0.171, alpha: 1)
    
    
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        do {
            try stack.dropAllData()
        } catch {
            print("Ebat' error")
        }
        */
        // Configure Firebase auth
        tableView.register(UINib(nibName: "NewTargetCell", bundle: nil), forCellReuseIdentifier: "NewTargetCell")
        configureAuth()
        configDatabase()
        configureStorage()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //dateFormatter.timeStyle = DateFormatter.Style.none
        //downloadTargets()

        
        
        
        
        
        // Set up Navigation controller
        setNavigationController(largeTitleDisplayMode: .never)


        /*
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Target")
        fr.sortDescriptors = [NSSortDescriptor(key: "completed", ascending: true),
                              NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
 */
        
        // Set notification for today and tomorrow
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //Auth.auth().currentUser?.unlink(fromProvider: "facebook.com", completion: nil)

        if let userID =  userID {
            databaseRef.child(Constants.RootFolders.Targets).child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? NSDictionary {
                    print(snapshot)
                    self.targets = value.allValues as [AnyObject]
                    self.tableView.reloadData()
                }
                //self.tableView.insertRows(at: [IndexPath(row: self.targets.count - 1, section: 0)], with: .automatic)
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        // tableView.reloadData() // Reload yable when view appears
    }
    
    
    // MARK: Initializers
    /*
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, style : UITableViewStyle = .plain) {
        fetchedResultsController = fc
        super.init(style: style)
    }
 */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // MARK: Config firebase
    func configDatabase(){
        databaseRef = Database.database().reference()
    }
    // Configure auth with Firebase
    func configureAuth() {
        let provider = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        // Create a listener to observe if auth status changed
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            if let activeUser = user {
                if self.user != activeUser {
                    self.user = activeUser
                    self.signedInStatus(isSignedIn: true)
                    var name = ""
                    if let email = activeUser.email {
                        name = email.components(separatedBy: "@")[0]
                    }
                    self.displayName = name
                    self.userID = Auth.auth().currentUser?.uid
                    self.downloadTargets()
                }
            } else {
                if let userID = self.userID {
                    self.databaseRef.child(Constants.RootFolders.Targets).child(userID).removeObserver(withHandle: self._refHandle)
                }
                self.targets = []
                self.tableView.reloadData()
                self.userID = nil
                self.signedInStatus(isSignedIn: false)
                self.loginSession()
            }
        }
    }
    func configureStorage() {
        storageRef = Storage.storage().reference()
    }
    func downloadTargets() {
        if let userID = userID {
            // Download targets data
            databaseRef.child(Constants.RootFolders.Targets).child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? NSDictionary {
                    print(snapshot)
                    self.targets = value.allValues as [AnyObject]
                    self.tableView.reloadData()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
            // Set observer on if data chenged
            _refHandle = databaseRef.child(Constants.RootFolders.Targets).child(userID).observe(.childChanged, with: { (snapshot) in
                // Redownload all targets data if something were changed
                self.databaseRef.child(Constants.RootFolders.Targets).child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? NSDictionary {
                        self.targets = value.allValues as [AnyObject]
                        self.tableView.reloadData()
                        self.makeNotification()
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    // MARK: Assist func
    // Get success percentage for target
    func getSuccessPercentage(checkIns:[String:String], dateBeginning: Date) -> String {
         var percentage = 0
        let dayInSeconds = 86400
        let countForDaysSinceBeginnigDay = Int(Date().timeIntervalSince(dateBeginning))/dayInSeconds
        var countForSucceedTargetsMarks = 0
        for (key, value) in checkIns {
            if value == "S" {
                countForSucceedTargetsMarks += 1
            }
        }
        percentage = Int((Double(countForSucceedTargetsMarks)/Double(countForDaysSinceBeginnigDay+1))*100)
        return "\(percentage)"
    }
    
    
    // Configure app and login button title depending on auth status
    func signedInStatus(isSignedIn: Bool) {
        // Here we set up App depending on login status
        addButton.isEnabled = isSignedIn
        if (isSignedIn) {
            loginButton.title = "Account"
        } else {
            loginButton.title = "Login"
        }
    }
    
    // Present firebase login viewController
    func loginSession() {
        // Show auth view controller
//        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
//        self.present(authViewController, animated: true, completion: nil)
        
        let signInVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        let signInNavController = UINavigationController(rootViewController: signInVC)
        signInNavController.modalPresentationStyle = .fullScreen
        self.present(signInNavController, animated: true, completion: nil)
    }
    
    //Save check in to FireBase
    func saveCheckIn(targetID:String,result:String) {
        if let userID = userID {
            let today = dateFormatter.string(from:Date())
            // Create targetRef by targetID
            let targetRef = databaseRef.child(Constants.RootFolders.Targets).child(userID).child(targetID)
            targetRef.child(Constants.Target.Checkins).child(today).setValue(result) //setValue(targetID)
            
        }
        
    }
    // Delte check in from Firebase
    func deleteCheckIn(targetID:String) {
        if let userID = userID {
            let today = dateFormatter.string(from:Date())
            // Create targetRef by targetID
            let targetRef = databaseRef.child(Constants.RootFolders.Targets).child(userID).child(targetID)
            targetRef.child(Constants.Target.Checkins).child(today).removeValue()
            
        }
        
    }
    // Check how many targets left to mark
    func targetsToMark() -> Int {
        var num: Int
        let today = Date()
        var toMark: Int
        var targetsCount = self.targets.count
        if targetsCount == 0 {
            return 0
        }
        num = targetsCount - 1
        toMark = targetsCount
        while num >= 0 {
            let indexPath = IndexPath(row: num, section: 0)
            guard let target = targets[num] as? [String:AnyObject] else {
                return 0
            }
            guard let checkIns = target[Constants.Target.Checkins] as? [String:String] else {
                return 0
            }
            let date = self.dateFormatter.string(from: Date())
            if let todayResult = checkIns[date] {
                toMark -= 1
            } else {
                print("nothing")
            }
            num -= 1
        }
        return toMark
    }

    
    // Create notification
    func makeNotification() {
        // Creating and setting up user notification
        let content = UNMutableNotificationContent()
        let contentMorning = UNMutableNotificationContent()
        let targetsToMarkCount = targetsToMark() // Check how many targets are unmarked
        var dateComponentsOne = DateComponents()
        dateComponentsOne.hour = 21
        dateComponentsOne.minute = 15
        var dateComponentsTwo = DateComponents()
        dateComponentsTwo.hour = 8
        dateComponentsTwo.minute = 01
        
        if targetsToMarkCount > 0 {
            if targetsToMarkCount == 1 {
                let bodyText = "You have just\(targetsToMarkCount) more target to check in!"
                content.body = bodyText
            } else {
                let bodyText = "You have \(targetsToMarkCount) more targets to check in!"
                content.body = bodyText
            }
        } else {
            let bodyText = "Well done for today. Keep it going tomorrow!"
            content.body = bodyText
        }
        setNotificationsForTime(dateComponents: dateComponentsOne, content: content)
        if currentTimeIsLater(hour: dateComponentsTwo.hour!, minute: dateComponentsTwo.minute!) {
            contentMorning.body = "It's easy. Make things done!"
        } else {
            contentMorning.body = content.body
        }
        setNotificationsForTime(dateComponents: dateComponentsTwo, content: contentMorning)
 
    }
    // Creates Date tomorrow at specific time
    func getTomorrowAt(hour: Int, minute: Int) -> Date {
        let today = Date()
        var addingDays = 0
        // Here we check if current time is more than setting time, depending on result we add 1 or 2 days
        if currentTimeIsLater(hour: hour, minute: minute) {
            addingDays = 2
        } else {
            addingDays = 1
        }
        let morrow = Calendar.current.date(byAdding: .day, value: addingDays, to: today)!
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: morrow)!
    }
    
    func currentTimeIsLater(hour:Int, minute:Int) -> Bool {
        let date = Date()
        let calendar = Calendar.current
        let hourNow = calendar.component(.hour, from: date)
        let minuteNow = calendar.component(.minute, from: date)
        if hourNow > hour {
            return true
        } else if hourNow == hour {
            if minuteNow >= minute {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func setNotificationsForTime(dateComponents: DateComponents, content: UNMutableNotificationContent) {
        // We create two notifications, one for today and one for tomorrow
        // Set notofocation for today
        let triggerForOne = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let requestforOne = UNNotificationRequest(identifier: "one\(dateComponents.hour!)\(dateComponents.minute!)", content: content, trigger: triggerForOne)
        // Set notofocation for tomorrow
        let contentForTwo = UNMutableNotificationContent()
        contentForTwo.body = "You stil didn't check in at any of your targets! Open app and reach your targets!"
        let triggerForTwo = UNTimeIntervalNotificationTrigger(timeInterval: abs(Date().timeIntervalSince(getTomorrowAt(hour: dateComponents.hour!, minute: dateComponents.minute!))), repeats: false)
        let requestforTwo = UNNotificationRequest(identifier: "two\(dateComponents.hour!)\(dateComponents.minute!)", content: contentForTwo, trigger: triggerForTwo)
        
       // UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(requestforTwo, withCompletionHandler: nil)
        UNUserNotificationCenter.current().add(requestforOne, withCompletionHandler: nil)
    }
    // MARK: Actions
    @IBAction func addButton(_ sender: Any) {
        // Segue to AddTargetVC setted uo in Storyboard
    }
    
    @IBAction func loginButton(_ sender: Any) {
        // Button works as login and as account button
        if loginButton.title == "Account" {
            // For account button open UserVC
            if let userID = userID {
                databaseRef.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    let userVC = self.storyboard?.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
                    userVC.title = value?[Constants.UserData.Username] as? String ?? "userID"
                    userVC.targetsCount = self.targets.count
                    self.navigationController?.pushViewController(userVC, animated: true)
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        } else {
            // For login button starying login session
            self.loginSession()
        }
    }
    
    deinit {
        // Remove auth listener
        Auth.auth().removeStateDidChangeListener(_authHandle)
        if let userID = userID {
            databaseRef.child(Constants.RootFolders.Targets).child(userID).removeObserver(withHandle: _refHandle)
        }
    }

}


extension TargetsVC {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewTargetCell") as! NewTargetCell
        // Presetting outfit for cell before it's filled with data
        cell.todayMark.backgroundColor = .white
        cell.todayMark.textColor = .black
//        cell.rightArror.isHidden = false
//        cell.percentage.alpha = 0
        cell.cellBackgroundView.backgroundColor = UIColor.random()
        // Check if Target excists
        let targetSnapshot = targets[indexPath.row]
        guard let target = targetSnapshot as? [String:AnyObject] else {
            return cell
        }
        // Check if TargetID excists
        guard let targetID = target[Constants.Target.TargetID] as? String else {
            return cell
        }
        // Fill title with information
        var title = target[Constants.Target.Title] as? String ?? ""
        title = " \(title) "
        // Set background image
        if let imageURL = target[Constants.Target.ImageURL] as? String {
            //    DispatchQueue.main.async {
            // Setting up fetch request to find item in core data for sertain targetID
            let fetchRequest:NSFetchRequest<TargetImages> = TargetImages.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "targetID", ascending: false)
            let predicate = NSPredicate(format:"targetID = %@", targetID)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.predicate = predicate
            if let result = try? self.stack.context.fetch(fetchRequest) {
                if result.count > 0 {
                    // If target for tsrget ID found, image is available and equal to the one on server setiing in as a targetImage
                    let targetImages = result[0]
                    print("downloading: \(targetImages.imageURL)")
                    if targetImages.imageURL == imageURL {
                        cell.targetImageView.image = UIImage(data: targetImages.fullImage)
                    } else {
                        if targetImages.imageURL == "" {
                            cell.targetImageView.image = UIImage(data: targetImages.fullImage)
                        }
                        Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX, completion: { (data, error) in
                            guard error == nil else {
                                print("Error downloading: \(error!)")
                                return
                            }
                            if let userImage = UIImage.init(data: data!) {
                                DispatchQueue.main.async {
                                    let cellImage = self.prepareCellImage(image: userImage)
                                    self.stack.context.delete(targetImages)
                                    _ = TargetImages(targetID: targetID, cellImage: cellImage, fullImage: data!, imageURL: imageURL, context: self.stack.context)
                                    cell.targetImageView.image = userImage
                                    self.stack.save()
                                }
                            }
                        })
                    }
                } else {
                    Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX, completion: { (data, error) in
                        guard error == nil else {
                            print("Error downloading: \(error!)")
                            return
                        }
                        if let userImage = UIImage.init(data: data!) {
                            DispatchQueue.main.async {
                                let cellImage = self.prepareCellImage(image: userImage)
                                _ = TargetImages(targetID: targetID, cellImage: cellImage, fullImage: data!, imageURL: imageURL, context: self.stack.context)
                                cell.targetImageView.image = userImage
                                self.stack.save()
                            }
                        }
                    })
                }
            }
            //  }
        }
        // Fill check ins history
        if let checkIns = target[Constants.Target.Checkins] as? [String:String] {
            if let todayResult = checkIns[self.dateFormatter.string(from: Date())] {
                if todayResult == "F" {
                    cell.todayMark.backgroundColor = redColor
                    cell.todayMark.textColor = .white
//                    cell.rightArror.isHidden = true
                } else if todayResult == "S" {
                    cell.todayMark.backgroundColor = greenColor
                    cell.todayMark.textColor = .white
//                    cell.rightArror.isHidden = true
                }
            } else {
                cell.todayMark.backgroundColor = .white
                cell.todayMark.textColor = .black
//                cell.rightArror.isHidden = false
            }
            var dayForChecking = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
            let dateBeginning = dateFormatter.date(from:(target[Constants.Target.DateBeginning] as! String))!
            let targetPercentage = self.getSuccessPercentage(checkIns: checkIns, dateBeginning: dateBeginning)
            if let userID = userID {
                if let percentage = target[Constants.Target.Percentage] as? String, percentage == targetPercentage {
                    // No need to resave the same data, so we do nothing here
                } else {
                    // Save targets percentage to FB
                    databaseRef.child(Constants.RootFolders.Targets).child(userID).child(targetID).child(Constants.Target.Percentage).setValue(targetPercentage)
                    var sumRating = 0
                    let numTargets = targets.count
                    for target in targets {
                        if let target = target as? [String:AnyObject] {
                            if let checkingTargetID = target[Constants.Target.TargetID] as? String, checkingTargetID == targetID {
                                // If it's the same target use new target's percentage
                                sumRating += Int(targetPercentage)!
                            } else {
                                if let percantageString = target[Constants.Target.Percentage] as? String, let percantage = Int(percantageString) {
                                    sumRating += percantage
                                }
                            }
                        }
                    }
                    let userPercentage = String(sumRating/numTargets)
                    databaseRef.child(Constants.RootFolders.Users).child(userID).child(Constants.UserData.Percentage).setValue(userPercentage)
                }
            }
//            cell.percentage.text = " \(targetPercentage)% "
//            cell.percentage.alpha = 1
            
            for mark in cell.marks {
                if dayForChecking >= dateBeginning {
                    if let todayResult = checkIns[self.dateFormatter.string(from: dayForChecking)] {
                        mark.alpha = 1
                        if todayResult == "F" {
                            mark.backgroundColor = redColor
                        } else if todayResult == "S" {
                            mark.backgroundColor = greenColor
                        }
                    } else {
                        mark.alpha = 1
                        mark.backgroundColor = redColor
                    }
                } else {
                    mark.alpha = 0
                }
                dayForChecking = Calendar.current.date(byAdding: .day, value: +1, to: dayForChecking)!
            }
        }
        cell.titleLabel.text = title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targets.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Open AddTargetVC in Editing moode with presetted data
        let targetSnapshot = targets[indexPath.row]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddTargetVC") as! AddTargetVC
        controller.editingMode = true
        controller.targetSnapshot = targetSnapshot
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let targetSnapshot = targets[indexPath.row]
        // Check if target, targetID and userID excists
        guard let target = targetSnapshot as? [String:AnyObject] else {
            return nil
        }
        guard let targetID = target[Constants.Target.TargetID] as? String else {
            return nil
        }
        guard let userID = userID else {
            return nil
        }
        let today = Date()
        // Create different options for "Swipe left to do smtn"
        let failAction = UITableViewRowAction(style: .normal, title: "Failed") {action,arg  in
            //handle delete
            self.saveCheckIn(targetID: targetID, result: "F")
            self.makeNotification()
        }
        failAction.backgroundColor = redColor
        let successAction = UITableViewRowAction(style: .normal, title: "Succeed") {action,arg  in
            //handle edit
            self.saveCheckIn(targetID: targetID, result: "S")
            self.makeNotification()
        }
        successAction.backgroundColor! = greenColor
        let result = (tableView.cellForRow(at: indexPath) as! NewTargetCell).todayMark.backgroundColor
        let unmarkAction = UITableViewRowAction(style: .normal, title: "Unmark") {action,arg  in
            self.deleteCheckIn(targetID: targetID)
            self.makeNotification()
        }
        unmarkAction.backgroundColor = .darkGray
        if result != .white {
            return [unmarkAction]
        } else {
            return [successAction, failAction]
        }
    }
}
