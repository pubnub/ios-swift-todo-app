//
//  ViewController.swift
//  ToDoList
//
//  Created by Keith Martin on 5/18/16.
//  Copyright © 2016 Keith Martin. All rights reserved.
//

import UIKit
import PubNub

struct TaskItem {
    var uuid: String
    var task: String
}

class TaskItemListViewController: UIViewController, PNObjectEventListener, UITableViewDelegate, UITableViewDataSource, PassTaskItemBackDelegate {
    
    var mainChannelName: String = ""
    var deletedChannelName: String = ""
    var taskListItems: [TaskItem] = []
    var deletedTaskItems: [TaskItem] = []
    var allTaskItems: [TaskItem] = []
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
    let serialQueue: dispatch_queue_t = dispatch_queue_create("pageHistoryQueue", DISPATCH_QUEUE_SERIAL)
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var fromAddTaskVC: Bool = false

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.title = mainChannelName + " to-do list"
        showActivityIndicator()
        tableView.dataSource = self
        tableView.delegate = self
        appDelegate.client.addListener(self)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        //Check if the segue is coming from the add task view controller with flag
        //If it is, don't retrieve history from PubNub
        if !fromAddTaskVC {
            showActivityIndicator()
            dispatch_async(serialQueue) { [unowned self] () -> Void in
                self.deletedTaskItems = self.pageHistory(self.deletedChannelName)
                self.allTaskItems = self.pageHistory(self.mainChannelName)
                self.checkAgainstDeletedAndUpdateTable()
            }
        } else {
            fromAddTaskVC = false
        }
    }
    
    
    //When user swipes to delete, a message is sent to the "deleted" channel
    //This makes sure that when a new user joins, these messages won't be shown in their todo list
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let message : [String : AnyObject] = ["uuid" : taskListItems[indexPath.row].uuid, "taskItem" : taskListItems[indexPath.row].task, "index" : indexPath.row]
            appDelegate.client.publish(message, toChannel: self.deletedChannelName, withCompletion: { (status) in
                self.showActivityIndicator()
                if status.error == true {
                    self.activityIndicator.stopAnimating()
                }
            })
        }
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskListItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell")! as UITableViewCell
        cell.textLabel?.text = taskListItems[indexPath.row].task
        return cell
    }
    
    
    //When a message is received, it is added to the tableview if it's not from the "deleted" channel
    //Otherwise, it's removed from the table
   func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
        if message.data.subscribedChannel != deletedChannelName {
            activityIndicator.stopAnimating()
            taskListItems.append(TaskItem(uuid: message.data.message!["uuid"] as! String, task: message.data.message!["taskItem"] as! String))
            tableView.reloadData()
        } else {
            activityIndicator.stopAnimating()
            taskListItems.removeAtIndex(message.data.message!["index"] as! Int)
            let indexPath = NSIndexPath(forRow: message.data.message!["index"] as! Int, inSection: 0)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    //Page history of specified channel using semaphore and return array with history task items
    func pageHistory(channelName: String) -> [TaskItem] {
        
        var uuidArray: [TaskItem] = []
        var shouldStop: Bool = false
        var isPaging: Bool = false
        var startTimeToken: NSNumber = 0
        let itemLimit: Int = 100
        let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        
        self.appDelegate.client.historyForChannel(channelName, start: nil, end: nil, limit: 100, reverse: true, includeTimeToken: true, withCompletion: { (result, status) in
            for message in (result?.data.messages)! {
                if let resultMessage = message["message"] {
                    uuidArray.append(TaskItem(uuid: resultMessage!["uuid"] as! String, task: resultMessage!["taskItem"] as! String))
                }
            }
            
            if let endTime = result?.data.end {
                startTimeToken = endTime
            }
            
            if result?.data.messages.count == itemLimit {
                    isPaging = true
                }
                dispatch_semaphore_signal(semaphore)
            })
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        while isPaging && !shouldStop {
            self.appDelegate.client.historyForChannel(channelName, start: startTimeToken, end: nil, limit: 100, reverse: true, includeTimeToken: true, withCompletion: { (result, status) in
                for message in (result?.data.messages)! {
                    if let resultMessage = message["message"] {
                        uuidArray.append(TaskItem(uuid: resultMessage!["uuid"] as! String, task: resultMessage!["taskItem"] as! String))
                    }
                }
                
                if let endTime = result?.data.end {
                    startTimeToken = endTime
                }
                
                if result?.data.messages.count < itemLimit {
                    shouldStop = true
                }
                dispatch_semaphore_signal(semaphore)
            })
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }
        return uuidArray
    }
    
    
    //Check all history items against deleted items and update tableView
    func checkAgainstDeletedAndUpdateTable() {
            for task in self.allTaskItems {
                if !self.deletedTaskItems.contains({$0.uuid == task.uuid}) {
                    self.taskListItems.append(TaskItem(uuid: task.uuid, task: task.task))
                }
            }
        //Update UI on main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            })
    }
    
    
    //Delegate method used to return item from TaskItemViewController
    func passTaskItemBack(taskItem: TaskItem) {
            fromAddTaskVC = true
            let message : [String : AnyObject] = ["uuid" : taskItem.uuid, "taskItem" : taskItem.task]
            appDelegate.client.publish(message, toChannel: mainChannelName, withCompletion: nil)
    }
    
    //Set delegate
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let taskItemViewController = segue.destinationViewController as! TaskItemViewController
        taskItemViewController.delegate = self
    } 
    
    //Spinning indicator when loading request
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
}

