//
//  MasterViewController.swift
//  FacebookMessage
//
//  Created by Swarup_Pattnaik on 26/09/16.
//  Copyright © 2016 Swarup_Pattnaik. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
//    var detailViewController: DetailViewController? = nil
    
    var contactsArray = NSMutableArray()// data model object
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let modelURL = NSBundle.mainBundle().URLForResource("Contacts", withExtension: "json")!
            let jsonData = NSData.init(contentsOfURL: modelURL)

            let object = try NSJSONSerialization.JSONObjectWithData(_:jsonData!, options:.MutableLeaves) as! [String:AnyObject]
            if let contacts = object["contacts"] as? [AnyObject] {
                contactsArray.addObjectsFromArray(contacts)
            }
//            print(object["contacts"]!)

            self.title = "Contacts"
        }
        catch {
            let nserror = error as NSError
            NSLog("String read error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

//        if let split = self.splitViewController {
//            let controllers = split.viewControllers
//            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        self.tableView.reloadData()
//        autoreleasepool{updateTableView()}
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let object = self.contactsArray[indexPath.row]
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.title = object.valueForKey("name")! as? String
                controller.userDetails = object

                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
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
        let key = object["avatarID"]
        cell.detailTextLabel!.text = NSUserDefaults.standardUserDefaults().objectForKey(key!) as? String
    }
}