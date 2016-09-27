//
//  MasterViewController.swift
//  FacebookMessage
//
//  Created by Swarup_Pattnaik on 26/09/16.
//  Copyright © 2016 Swarup_Pattnaik. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var contactsArray = NSMutableArray()// data model object
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        do {
            let modelURL = NSBundle.mainBundle().URLForResource("Contacts", withExtension: "json")!
            let jsonData = NSData.init(contentsOfURL: modelURL)

            let object = try NSJSONSerialization.JSONObjectWithData(_:jsonData!, options:.MutableLeaves) as! [String:AnyObject]
            if let contacts = object["contacts"] as? [AnyObject] {
                contactsArray.addObjectsFromArray(contacts)
            }
//            print(object["contacts"]!)

        }
        catch {
            let nserror = error as NSError
            NSLog("String read error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(showComposeViewModally(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
//        autoreleasepool{updateTableView()}
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showComposeViewModally(sender: AnyObject) {
        self.performSegueWithIdentifier("showComposeView", sender: sender)
    }
    
    func insertNewObject(message: [String:AnyObject]) {
        let context = self.managedObjectContext!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context)
        
        newManagedObject.setValue(message["timeStamp"] as? String, forKey: "timeStamp")
        newManagedObject.setValue(message["toName"] as? String, forKey: "toName")
        newManagedObject.setValue(message["fromName"] as? String, forKey: "fromName")
        newManagedObject.setValue(message["text"] as? String, forKey: "text")
        newManagedObject.setValue(message["isSent"] as? Bool, forKey: "isSent")
        
        // Save the context.
        do {
            try context.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
    
    func deleteObjectForFetchRequest(fetchRequest: NSFetchRequest) {
        let batchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchRequest.resultType = .ResultTypeCount
        // Batch Delete Request
        do {
            let results = try self.managedObjectContext!.executeRequest(_:batchRequest)
            print("batchRequest result \(results)")
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let object = self.contactsArray[indexPath.row]
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
//                controller.title = toName
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        //        if segue.identifier == "showComposeView" {
        //
        //        }
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return contactsArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = contactsArray[indexPath.row] as! [String: String]
        self.configureCell(cell, withObject: object)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    
    func configureCell(cell: UITableViewCell, withObject object: [String: String]) {
        cell.textLabel!.text = object["name"]
//        cell.detailTextLabel!.text = object["text"]
    }
}