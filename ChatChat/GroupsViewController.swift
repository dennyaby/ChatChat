//
//  GroupViewController.swift
//  ChatChat
//
//  Created by Admin on 17.04.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class GroupsViewController: UITableViewController {
    
    var ref = Firebase(url: "https://blinding-inferno-500.firebaseio.com")
    
    var groups = [String]()
    
    var detailGroups = [[String: AnyObject]]()
    
    var selectedGroupName: String?
    
    var helper = Helper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        let uid = ref.authData.uid
        let groupsRef = ref.childByAppendingPath("groups")
        groupsRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            print(snapshot.value)
            guard let groupName = snapshot.value["name"] as! String? else {
                return
            }
            guard let admin = snapshot.value["admin"] as! String? else {
                return
            }
            var users = [String: AnyObject]()
            if let usersI = snapshot.value["users"] as! [String: AnyObject]? {
                users = usersI
            }
            self.detailGroups.append(["name": groupName, "admin": admin, "users": users])
            if uid == admin {
                self.groups.append(groupName)
                self.tableView.reloadData()
            }
            for user in users.values {
                if uid == user as! String {
                    if !self.groups.contains(groupName) {
                        self.groups.append(groupName)
                        self.tableView.reloadData()
                        break
                    }
                }
            }
        })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if groups.count > 0 {
            return 2
        } else {
            return 1
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        print("View Did Appear")
        super.viewDidAppear(animated)
        
        let uid = ref.authData.uid
        let groupsRef = ref.childByAppendingPath("groups")
        groupsRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            guard let groupName = snapshot.value["name"] as! String? else {
                return
            }
            guard let admin = snapshot.value["admin"] as! String? else {
                return
            }
            var users = [String: AnyObject]()
            if let usersI = snapshot.value["users"] as! [String: AnyObject]? {
                users = usersI
            }
            self.detailGroups.append(["name": groupName, "admin": admin, "users": users])
            if uid == admin {
                if !self.groups.contains(groupName) {
                    self.groups.append(groupName)
                    self.tableView.reloadData()
                }
            }
            for user in users.values {
                if uid == user as! String {
                    if !self.groups.contains(groupName) {
                        self.groups.append(groupName)
                        self.tableView.reloadData()
                        break
                    }
                }
            }
        })

        
        tableView.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("View Did Dissappear")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groups.count > 0 {
            if section == 0 {
                return groups.count
            } else if section == 1 {
                return 1
            }
        } else {
            return 1
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if groups.count > 0 && indexPath.section == 0 {
            selectedGroupName = groups[indexPath.item]
            performSegueWithIdentifier("ShowGroupChat", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowGroupChat" {
            let database = Database.sharedInstance
            database.groupName = selectedGroupName
            
            let chatVc = segue.destinationViewController as! GroupChatViewController
            chatVc.senderId = ref.authData.uid
            chatVc.navigationItem.title = selectedGroupName
            chatVc.senderDisplayName = helper.getMailWithUid(ref.authData.uid)
            chatVc.groupName = selectedGroupName
            for group in detailGroups {
                if group["name"] as? String == selectedGroupName {
                    if group["admin"] as? String == ref.authData.uid {
                        chatVc.admin = true
                    } else {
                        chatVc.admin = false
                    }
                    break
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (groups.count > 0 && indexPath.section == 1) || (groups.count == 0 && indexPath.section == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewGroupCell", forIndexPath: indexPath)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("GroupsCell", forIndexPath: indexPath)
            cell.textLabel?.text = groups[indexPath.item]
        
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Groups"
        }
        return ""
    }
}