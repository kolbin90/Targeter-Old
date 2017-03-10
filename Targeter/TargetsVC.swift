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
        /* do {
         try stack.dropAllData()
         } catch {
         print("Ebat' error")
         } */
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Target")
        fr.sortDescriptors = [NSSortDescriptor(key: "active", ascending: true),
                              NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
        
        if let successList = target.successList as? Set<Success>{
            print(successList)
            print("________")
            print(target.successList!)
            for day in successList {
                // let successDay = day as? Success
                if let daySuccess = day as? Success {
                    if daySuccess.success {
                        cell.dot1.tintColor = .green
                        cell.dot1.image! = cell.dot1.image!.withRenderingMode(.alwaysTemplate)
                        
                    } else {
                        cell.dot1.tintColor = .red
                        cell.dot1.image! = cell.dot1.image!.withRenderingMode(.alwaysTemplate)
                    }
                }
                
            }
        }
        // Sync notebook -> cell
        //cell.textLabel?.text = target.title
        //cell.detailTextLabel?.text = target.descriptionCompletion
        // cell.dot1.tintColor = .green
        //cell.dot1.image! = cell.dot1.image!.withRenderingMode(.alwaysTemplate)
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
        
        
        if let successList = target.successList as? Set<Success>{
            if successList.count > 0 {
                /*  for day in successList {
                 // let successDay = day as? Success
                 if let daySuccess = day as? Success {
                 if daySuccess.success {
                 cell.dot1.tintColor = .green
                 cell.dot1.image! = cell.dot1.image!.withRenderingMode(.alwaysTemplate)
                 
                 } else {
                 cell.dot1.tintColor = .red
                 cell.dot1.image! = cell.dot1.image!.withRenderingMode(.alwaysTemplate)
                 }
                 }
                 
                 } */
                let unmarkAction = UITableViewRowAction(style: .normal, title: "Unmark") {action in
                    for day in successList {
                        let successDay = day
                        self.stack.context.delete(successDay)
                        self.stack.save()
                    }
                }
                return [unmarkAction]
                
            } else {
                
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
                
                return [failAction, successAction]
                
            }
        }
        return nil
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

