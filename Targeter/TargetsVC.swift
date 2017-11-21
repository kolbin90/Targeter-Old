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
import FirebaseAuthUI
import FirebaseGoogleAuthUI


// MARK: - CoreDataTableViewController: UITableViewController

class TargetsVC: UITableViewController {
    // MARK: Outlets
    @IBOutlet weak var loginButton: UIBarButtonItem!
    
    // MARK: Properties
    let greenColor = UIColor.init(red: 46/256, green: 184/256, blue: 46/256, alpha: 1)
    let redColor = UIColor(red: 0.872, green: 0.255, blue: 0.171, alpha: 1)
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle! // Listens when Firebase Auth changed status
    var user: User?
    var displayName = "Anonymous"  // name before user logged in
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData()
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure Firebase auth
        configureAuth()
        /*
         do {
         try stack.dropAllData()
         } catch {
         print("Ebat' error")
         }
         */
        
        
        // Set up Navigation controller
        setNavigationController()

        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Target")
        fr.sortDescriptors = [NSSortDescriptor(key: "completed", ascending: true),
                              NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Set notification for today and tomorrow
        makeNotification()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData() // Reload yable when view appears
    }
    
    
    // MARK: Initializers
    
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, style : UITableViewStyle = .plain) {
        fetchedResultsController = fc
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // MARK: Assist func
    // Check if selected day was marked as succeed or as failed in success list
    func todayIn(successList:Set<Success>,today:Date) -> (String,Success?){
        for day in successList {
            if Calendar.current.isDate(day.date, equalTo: today, toGranularity:.day) {
                if day.success {
                    return ("succeed", day)
                } else {
                    return ("failed", day)
                }
            }
        }
        return ("nothing", nil)
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
                    let name = activeUser.email!.components(separatedBy: "@")[0]
                    self.displayName = name
                }
            } else {
                self.signedInStatus(isSignedIn: false)
                self.loginSession()
            }
        }
    }
    
    // Configure app and login button title depending on auth status
    func signedInStatus(isSignedIn: Bool) {
        if (isSignedIn) {
            loginButton.title = "Account"
        } else {
            loginButton.title = "Login"
        }
    }
    
    // Present firebase login viewController
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    // Check how many targets are marked for today
    func targetsToMark() -> Int {
        var num: Int
        let today = Date()
        var toMark: Int
        //let target = self.fetchedResultsController!.object(at: indexPath) as! Target
        
        guard let targetsCount = self.fetchedResultsController?.fetchedObjects?.count else {
            return 0
        }
        num = targetsCount - 1
        toMark = targetsCount
        while num >= 0 {
            let indexPath = IndexPath(row: num, section: 0)
            let target = self.fetchedResultsController!.object(at: indexPath) as! Target
            if let successList = target.successList as? Set<Success>, (successList.count > 0) {
                let success = self.todayIn(successList: successList, today: today).0
                switch success {
                case "succeed":
                    toMark -= 1
                case "failed":
                    toMark -= 1
                case "nothing":
                    print("nothing")
                default:
                    print("Error!")
                }
            }
            num -= 1
        }
        return toMark
    }
    
    // Create notification
    func makeNotification() {
        // Creating and setting up user notification
        let content = UNMutableNotificationContent()
        let targetsToMarkCount = targetsToMark() // Check how many targets are unmarked
        if targetsToMarkCount > 0 {
            if targetsToMarkCount == 1 {
                let bodyText = "You have just\(targetsToMarkCount) more target to mark!"
                content.body = bodyText
            } else {
                let bodyText = "You have \(targetsToMarkCount) more targets to mark!"
                content.body = bodyText
            }
        } else {
            let bodyText = "Well done for today. Keep it going tomorrow!"
            content.body = bodyText
        }
        // Time 21:15 is random
        var dateComponentsOne = DateComponents()
        dateComponentsOne.hour = 21
        dateComponentsOne.minute = 15
        
        var dateComponentsTwo = DateComponents()
        dateComponentsTwo.hour = 9
        dateComponentsTwo.minute = 15
        
        setNotificationsForTime(dateComponents: dateComponentsOne, content: content)
        setNotificationsForTime(dateComponents: dateComponentsTwo, content: content)
        
    }
    // Creates Date tomorrow at specific time
    func getTomorrowAt(hour: Int, minutes: Int) -> Date {
        let today = Date()
        let morrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return Calendar.current.date(bySettingHour: hour, minute: minutes, second: 0, of: morrow)!
    }
    
    func setNotificationsForTime(dateComponents: DateComponents, content: UNMutableNotificationContent) {
        // We create two notifications, one for today and one for tomorrow
        // Set notofocation for today
        let triggerForOne = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let requestforOne = UNNotificationRequest(identifier: "one\(dateComponents.hour!)\(dateComponents.minute!)", content: content, trigger: triggerForOne)
        // Set notofocation for tomorrow
        let contentForTwo = UNMutableNotificationContent()
        contentForTwo.body = "You stil didn't mark any of your targets! Open app and reach your targets!"
        let triggerForTwo = UNTimeIntervalNotificationTrigger(timeInterval: abs(Date().timeIntervalSince(getTomorrowAt(hour: dateComponents.hour!, minutes: dateComponents.minute!))), repeats: false)
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
        // Button works as login and as logout
        if loginButton.title == "Account" {
            // For logout button trying to sign out
            let userVC = storyboard?.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
            navigationController?.pushViewController(userVC, animated: true)
        } else {
            // For login button starying login session
            self.loginSession()
        }
    }
    
    deinit {
        // ref.child("messages").removeObserver(withHandle: _refHandle)
        // Remove auth listener
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
}

// MARK: - CoreDataTableViewController

extension TargetsVC {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        DispatchQueue.global().async {
            // Find the right notebook for this indexpath
            let target = self.fetchedResultsController!.object(at: indexPath) as! Target
            
            // Create the cell
            let cell = cell as! TargetCell
            var dayForStartChecking = Date()
            var dayForChecking = Date()
            let numberOfMarksInCell = 14
            let today = Date()
            var num = 0
            var countForSucceedTargetsMarks = 0
            var countForDaysSinceBeginnigDay = 0
            var dotsArray: [UIImageView] = [cell.dot1, cell.dot2, cell.dot3, cell.dot4, cell.dot5, cell.dot6, cell.dot7, cell.dot8, cell.dot9, cell.dot10, cell.dot11, cell.dot12, cell.dot13, cell.dot14]
            var daysArray:[UILabel] = [cell.day1, cell.day2, cell.day3, cell.day4, cell.day5, cell.day6, cell.day7, cell.day8, cell.day9, cell.day10, cell.day11, cell.day12, cell.day13, cell.day14]
            var successList: Set<Success>?
            DispatchQueue.main.async {
                // Round corners for view
                cell.cellView.layer.cornerRadius = 15
                // Set background picture, if Target have one
                cell.backgroundImage.image = nil
                if let imageData = target.cellImage {
                    if let image = UIImage(data: imageData) {
                        cell.backgroundImage.image = image
                    }
                }
            }
            // Check if target should be completed and figure dates
            if let endingDay = target.dayEnding, endingDay < dayForChecking  {
                dayForChecking = endingDay
                dayForStartChecking = endingDay
                if !target.completed {
                    DispatchQueue.main.async {
                        target.completed = true
                        self.stack.save()
                    }
                }
            }
            //
            if let successListTarget = target.successList as? Set<Success>, (successListTarget.count > 0) {
                successList = successListTarget
                // Count number of succeed targets
                for mark in successList! {
                    if mark.success {
                        countForSucceedTargetsMarks += 1
                    }
                }
            } else {
                successList = nil
            }
            
            
            
            
            
            while num < numberOfMarksInCell {
                // Color images on success and fail
                let dayImageView = dotsArray[num]
                let dayLabel = daysArray[num]
                // If Mark is out of date (before beginning date) give them light gray color
                if dayForChecking < target.dayBeginning {
                    DispatchQueue.main.async {
                        dayImageView.tintColor = UIColor.groupTableViewBackground
                        dayLabel.textColor = .lightGray
                        dayImageView.image! = cell.dot1.image!.withRenderingMode(.alwaysTemplate)
                    }
                } else {
                    // Check if Success list contains anyrhing
                if let successList = successList {
                        let dotColor:UIColor!
                        let success = self.todayIn(successList: successList, today: dayForChecking).0
                        switch success {
                        case "succeed":
                            dotColor = self.greenColor
                        case "failed":
                            dotColor = self.redColor
                        case "nothing":
                            if today == dayForChecking {
                                dotColor = .black
                            } else {
                                dotColor = self.redColor
                            }
                        default:
                            dotColor = .black
                            print("Error!")
                        }
                    
                    
                        DispatchQueue.main.async {
                            dayImageView.tintColor = dotColor
                            dayImageView.image! = cell.dot1.image!.withRenderingMode(.alwaysTemplate)
                        }
                    } else {
                        DispatchQueue.main.async {
                            dayImageView.tintColor = .black
                            dayImageView.image! = cell.dot1.image!.withRenderingMode(.alwaysTemplate)
                        }
                    }
                }
                // Give labels name of last 14 days
                let day = Calendar.current.component(.day, from: dayForChecking)
                var labelText = String(day)
                if Calendar.current.isDate(dayForChecking, equalTo: dayForStartChecking, toGranularity:.day) {
                    let month = Calendar.current.component(.month, from: dayForChecking)
                    let year = Calendar.current.component(.year, from: dayForChecking)
                    labelText = "\(day)/\(month)\n\(year)"
                }
                DispatchQueue.main.async {
                    dayLabel.text = labelText
                }
                
                // Change "today" for a one day before
                dayForChecking = Calendar.current.date(byAdding: .day, value: -1, to: dayForChecking)!
                num += 1
            }
            DispatchQueue.main.async {
                cell.label.text = target.title
                // Count percentage of succes for target
                var percentage = 0
                let dayInSeconds = 86400
                countForDaysSinceBeginnigDay = Int(Date().timeIntervalSince(target.dayBeginning))/dayInSeconds
                percentage = Int((Double(countForSucceedTargetsMarks)/Double(countForDaysSinceBeginnigDay+1))*100)
                // If target completed we add "Completed with?
                if target.completed {
                    cell.completedLabel.text = "Completed with: \(percentage)%"
                } else {
                    cell.completedLabel.text = "\(percentage)%"
                }
                cell.completedLabel.isHidden = false
            }
            
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TargetCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let target = self.fetchedResultsController!.object(at: indexPath) as! Target
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddTargetVC") as! AddTargetVC
        controller.editingMode = true
        controller.target = target
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let target = fetchedResultsController?.object(at: indexPath) as! Target
        let today = Date()
        // Create different options for "Swipe left to do smtn"
        let failAction = UITableViewRowAction(style: .normal, title: "Failed") {action,arg  in
            //handle delete
            let date = Date()
            let success = Success.init(date: date, success: false, context: self.stack.context)
            target.addToSuccessList(success)
            self.stack.save()
            self.makeNotification()
        }
        failAction.backgroundColor = redColor
        let successAction = UITableViewRowAction(style: .normal, title: "Succeed") {action,arg  in
            //handle edit
            let date = Date()
            let success = Success.init(date: date, success: true, context: self.stack.context)
            target.addToSuccessList(success)
            self.stack.save()
            self.makeNotification()
        }
        successAction.backgroundColor! = greenColor 
        
        
        if let successList = target.successList as? Set<Success>, (successList.count > 0) {
            let (success, todayInSuccessList) = todayIn(successList: successList, today: today)
            let unmarkAction = UITableViewRowAction(style: .normal, title: "Unmark") {action,arg  in
                self.stack.context.delete(todayInSuccessList!)
                self.stack.save()
                self.makeNotification()
            }
            unmarkAction.backgroundColor = .darkGray
            switch success {
            case "succeed",
                 "failed":
                return [unmarkAction]
            case "nothing":
                return [successAction, failAction]
            default:
                print("Error!")
                return [successAction, failAction]
            }
        } else {
            return [successAction, failAction]
        }
    }
}

// MARK: - CoreDataTableViewController (Table Data Source)

extension TargetsVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let fc = fetchedResultsController {
            return fc.sections![section].name
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.section(forSectionIndexTitle: title, at: index)
        } else {
            return 0
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if let fc = fetchedResultsController {
            return fc.sectionIndexTitles
        } else {
            return nil
        }
    }
}

// MARK: - CoreDataTableViewController (Fetches)

extension TargetsVC {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}

// MARK: - CoreDataTableViewController: NSFetchedResultsControllerDelegate

extension TargetsVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            tableView.insertSections(set, with: .fade)
        case .delete:
            tableView.deleteSections(set, with: .fade)
        default:
            // irrelevant in our case
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

