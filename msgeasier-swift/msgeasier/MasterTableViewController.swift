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
    
        
    var friends = [
        MessageItem(name: "Daniel", photo: UIImage(named: "1.jpg"), lastSeen: NSDate(), msg:"Hi ya, wassup"),
        MessageItem(name: "Colin", photo: UIImage(named: "youngman.jpg"), lastSeen: NSDate(),msg:"What you upto?"),
        MessageItem(name: "Livia", photo: UIImage(named: "gina_portrait.jpg"), lastSeen: NSDate(),msg:"Dude, where you been?"),
        MessageItem(name: "gina", photo: UIImage(named:"2.jpg"), lastSeen: NSDate(),msg:"Gosh, long time no see")
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
                
        
        println("\(friends[indexPath.item].photo)")
        /*cell.friendName.text = friends[indexPath.item].name
        cell.friendPhoto! = UIImageView(image:friends[indexPath.item].photo)
        cell.lastSeen.text = friends[indexPath.item].lastSeen.description
        cell.message.text = friends[indexPath.item].msg*/
        let item = friends[indexPath.row]
        cell.messageItem = item
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
