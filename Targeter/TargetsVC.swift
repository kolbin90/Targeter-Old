//
//  TargetsVC.swift
//  Targeter
//
//  Created by mac on 3/8/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit
import CoreData

// MARK: - CoreDataTableViewController: UITableViewController

class TargetsVC: UITableViewController {
    
    // MARK: Properties
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData()
        }
    }
    
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
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Target")
        fr.sortDescriptors = [NSSortDescriptor(key: "active", ascending: true),
                              NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()

    }
    
    // MARK: Initializers
    
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, style : UITableViewStyle = .plain) {
        fetchedResultsController = fc
        super.init(style: style)
    }
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Actions
    @IBAction func addButton(_ sender: Any) {
    }
    
    @IBAction func settingsButton(_ sender: Any) {
    }
}

// MARK: - CoreDataTableViewController

extension TargetsVC {
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Find the right notebook for this indexpath
        let target = fetchedResultsController!.object(at: indexPath) as! Target
        
        // Create the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TargetCell
        var today = Date()
        let numberOfMarksInCell = 14
        var num = 0
        var dotsArray: [UIImageView] = [cell.dot1, cell.dot2, cell.dot3, cell.dot4, cell.dot5, cell.dot6, cell.dot7, cell.dot8, cell.dot9, cell.dot10, cell.dot11, cell.dot12, cell.dot13, cell.dot14]
        var daysArray:[UILabel] = [cell.day1, cell.day2, cell.day3, cell.day4, cell.day5, cell.day6, cell.day7, cell.day8, cell.day9, cell.day10, cell.day11, cell.day12, cell.day13, cell.day14]
        //print(dotsArray)
        //var cellDays = cell.daysArray!
        if let imageData = target.picture {
            if let image = UIImage(data: imageData) {
                cell.backgroundImage.image! = image
            }
        }
        //
        while num < numberOfMarksInCell {
            // Color images on success and fail
            let dayImageView = dotsArray[num]
            
            //calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            
            // Check if Success list contains anyrhing
            
            if let successList = target.successList as? Set<Success>, (successList.count > 0) {
                let dotColor:UIColor!
                let success = todayIn(successList: successList, today: today).0
                switch success {
                case "succeed":
                    dotColor = .green
                case "failed":
                    dotColor = .red
                case "nothing":
                    dotColor = .darkGray
                default:
                    dotColor = .darkGray
                    print("Error!")
                }
                dayImageView.tintColor = dotColor
                dayImageView.image! = cell.dot1.image!.withRenderingMode(.alwaysTemplate)
            } else {
                dayImageView.tintColor = .darkGray
                dayImageView.image! = cell.dot1.image!.withRenderingMode(.alwaysTemplate)
            }
            
            // Give labels name of last 14 days
            let dayLabel = daysArray[num]
            let day = Calendar.current.component(.day, from: today)
            if Calendar.current.isDate(today, equalTo: Date(), toGranularity:.day) {
                let month = Calendar.current.component(.month, from: today)
                let year = Calendar.current.component(.year, from: today)
                dayLabel.text! = "\(day)/\(month)\n\(year)"
            } else {
                dayLabel.text! = String(day)
            }

            today = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            num += 1
        }
        cell.label.text = target.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        //detailVC.meme = memes[indexPath.row]
        //navigationController!.pushViewController(detailVC, animated: true)
        //    tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let target = fetchedResultsController?.object(at: indexPath) as! Target
        let today = Date()
        let failAction = UITableViewRowAction(style: .default, title: "Failed") {action in
            //handle delete
            let date = Date()
            let success = Success.init(date: date, success: false, context: self.stack.context)
            target.addToSuccessList(success)
            self.stack.save()
        }
        
        let successAction = UITableViewRowAction(style: .normal, title: "Succeed") {action in
            //handle edit
            let date = Date()
            let success = Success.init(date: date, success: true, context: self.stack.context)
            target.addToSuccessList(success)
            self.stack.save()
        }
        successAction.backgroundColor! = .green
        
        if let successList = target.successList as? Set<Success>, (successList.count > 0) {
            let (success, todayInSuccessList) = todayIn(successList: successList, today: today)
            let unmarkAction = UITableViewRowAction(style: .normal, title: "Unmark") {action in
                self.stack.context.delete(todayInSuccessList!)
                self.stack.save()
            }
            unmarkAction.backgroundColor = .darkGray
            switch success {
            case "succeed",
                 "failed":
                return [unmarkAction]
            case "nothing":
                return [failAction, successAction]
            default:
                print("Error!")
                return [failAction, successAction]
            }
        } else {
            return [failAction, successAction]
        }
    }
    //MARK: Assist func
    
    func todayIn(successList:Set<Success>,today:Date) -> (String,Success?){
        for day in successList {
            if Calendar.current.isDate(day.date, equalTo: today, toGranularity:.day) {
                if day.success {
                    return ("succeed", day)
                    //dayImageView.image! = cell.dot1.image!.withRenderingMode(.alwaysTemplate)
                } else {
                    return ("failed", day)
                }
            }
        }
        return ("nothing", nil)
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

