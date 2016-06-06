//
//  TaskViewController.swift
//  ToDoList
//
//  Created by Keith Martin on 5/23/16.
//  Copyright © 2016 Keith Martin. All rights reserved.
//

import UIKit

protocol PassTaskItemBackDelegate: class {
    func passTaskItemBack(taskItem: TaskItem)
}

class TaskItemViewController: UIViewController {

    weak var delegate: PassTaskItemBackDelegate?
    
    @IBOutlet weak var taskItemTextField: UITextField!
    
    @IBAction func addTaskItemAndReturn(sender: AnyObject) {
        if let text = taskItemTextField.text {
            if !text.isEmpty {
                delegate?.passTaskItemBack(TaskItem(uuid: NSUUID().UUIDString, task: taskItemTextField.text!))
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                showAlert("Cannot sumbit blank task")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationItem.hidesBackButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Dialogue showing error
    func showAlert(error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion:nil)
    }
}
