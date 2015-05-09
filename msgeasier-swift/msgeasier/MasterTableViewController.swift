//
//  MasterTableViewController.swift
//  msgeasier
//
//  Created by Gina Hagg on 5/6/15.
//  Copyright (c) 2015 Gina Hagg. All rights reserved.
//

import UIKit

class MasterTableViewController: UITableViewController {
    
     var detailViewController: ViewController? = nil
    
    struct friendd{
        var name:String
        var photo:UIImage?
        var lastSeen:NSDate = NSDate()
    }
    
    var friends = [
        friendd(name: "Daniel", photo: UIImage(named: "1.jpg"), lastSeen: NSDate()),
        friendd(name: "Colin", photo: UIImage(named: "youngman.jpg"), lastSeen: NSDate()),
        friendd(name: "Livia", photo: UIImage(named: "gina_portrait.jpg"), lastSeen: NSDate()),
        friendd(name: "gina", photo: UIImage(named:"2.jpg"), lastSeen: NSDate())
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? ViewController
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.friends.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendTableViewCell
                
        cell.friendName.text = friends[indexPath.item].name
        println("\(friends[indexPath.item].photo)")
        cell.friendPhoto! = UIImageView(image:friends[indexPath.item].photo)
        cell.lastSeen.text = friends[indexPath.item].lastSeen.description
        return cell
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        println("selected \(indexPath.item)")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("preareForSegue is called")
        if segue.identifier == "ShowChatWindow" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                println("selected row: \(indexPath)")
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! ViewController
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

}
