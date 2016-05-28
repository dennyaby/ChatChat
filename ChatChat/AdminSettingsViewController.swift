//
//  AdminSettingsViewController.swift
//  ChatChat
//
//  Created by Admin on 17.04.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit
import Foundation

class AdminSettingsViewController: UITableViewController {
    
    var groupName: String?
    var bots = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = groupName!
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.donePressed))
        doneButton.tintColor = UIColor.blueColor()
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if bots.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bots.count > 0 {
            if section == 0 {
                return bots.count
            } else {
                return 1
            }
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if bots.count > 0 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("BotCell", forIndexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("InviteCell", forIndexPath: indexPath)
            
            return cell
        }
    }
    
    func donePressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
