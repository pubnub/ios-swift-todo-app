//
//  SubscribedListViewController.swift
//  ToDoList
//
//  Created by Keith Martin on 5/31/16.
//  Copyright © 2016 Keith Martin. All rights reserved.
//

import UIKit
import PubNub

class SubscribedListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PNObjectEventListener {
    
    var channels: [String] = []
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let row = tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(row, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("channelCell")! as UITableViewCell
        cell.textLabel?.text = channels[indexPath.row]
        return cell
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Set the channel names from the selected row
        if let destinationVC = segue.destinationViewController as? TaskItemListViewController {
            destinationVC.mainChannelName = channels[tableView.indexPathForSelectedRow!.row]
            destinationVC.deletedChannelName = destinationVC.mainChannelName + "-deleted"
        }
    }
}
