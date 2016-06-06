//
//  AppDelegate.swift
//  ToDoList
//
//  Created by Keith Martin on 5/18/16.
//  Copyright © 2016 Keith Martin. All rights reserved.
//

import UIKit
import PubNub

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {

    var window: UIWindow?
    lazy var client: PubNub = {
        let config = PNConfiguration(publishKey: "pub-c-050a27d6-7ca2-46c4-89ba-ac40f9e49e4d", subscribeKey: "sub-c-4a296868-238d-11e6-8bc8-0619f8945a4f")
        let pub = PubNub.clientWithConfiguration(config)
        return pub
    }()

    override init() {
        super.init()
        client.addListener(self)
    }
    
    func client(client: PubNub, didReceiveStatus status: PNStatus) {
        if status.error {
            showAlert(status.error.description)
        }
    }
    
    //Dialogue showing error
    func showAlert(error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(OKAction)
        self.window?.rootViewController?.presentViewController(alertController, animated: true, completion:nil)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

