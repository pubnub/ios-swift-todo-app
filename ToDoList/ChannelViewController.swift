//
//  ChannelViewController.swift
//  ToDoList
//
//  Created by Keith Martin on 5/31/16.
//  Copyright © 2016 Keith Martin. All rights reserved.
//

import UIKit

class ChannelViewController: UIViewController {

    @IBOutlet weak var mainChannelName: UITextField!
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    //Check if input field has error
    func inputFieldHasError(text: String) -> Bool {
        if text.characters.count > 7000 {
            showAlert("Channel name cannot be more than 7000 characters.")
            return true
        } else if text.hasSuffix("-deleted") {
            showAlert("Channel name cannot end in -deleted.")
            return true
        } else if mainChannelName.text!.isEmpty {
            showAlert("Channel name cannot be blank.")
            return true
        }
        return false
    }
    
    
    
    //If input field has error, don't segue
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "showSubList" {
            return !inputFieldHasError(mainChannelName.text!)
        }
        return false
    }
    
    //Dialogue showing error
    func showAlert(error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion:nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //Go through subscribed channels and filter out all "deleted" channels and append to array in destination VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        appDelegate.client.subscribeToChannels([mainChannelName.text!, (mainChannelName.text! + "-deleted")], withPresence: true)
        let destinationVC: SubscribedListViewController = segue.destinationViewController as! SubscribedListViewController
        for channel in appDelegate.client.channels() {
            if !channel.hasSuffix("-deleted") {
                destinationVC.channels.append(channel)
            }
        }
        mainChannelName.text = ""
    }
}
