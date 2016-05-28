//
//  ChooseContactViewController.swift
//  ChatChat
//
//  Created by Admin on 17.04.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class ChooseContactViewController: UITableViewController {
    
    var ref: Firebase!
    var refContacts: Firebase!
    
    var groupName: String?
    
    var uid: String?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var contacts = [String: String]()
    var contactsArray: [String] {
        var arr = [String]()
        for value in contacts.values {
            arr.append(value)
        }
        return arr
    }
    
    var helper = Helper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.tintColor = UIColor.blueColor()
        let database = Database.sharedInstance
        groupName = database.getGroupName()
        print("Group name: \(groupName)")
        
        ref = Firebase(url: "https://blinding-inferno-500.firebaseio.com/")
        uid = ref!.authData.uid
        refContacts = ref!.childByAppendingPath("users").childByAppendingPath(ref!.authData.uid).childByAppendingPath("contacts")
        refContacts.observeEventType(.ChildAdded, withBlock: {snapshot in
            if !(snapshot.value is NSNull) {
                self.contacts[snapshot.key] = snapshot.value["mail"] as? String
                self.tableView.reloadData()
            }
        })
        
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChooseContactCell", forIndexPath: indexPath)
        if contacts.count > 0 {
            cell.textLabel!.text = contactsArray[indexPath.item]
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let receiverId =  helper.getUidWithMail(contactsArray[indexPath.item])
        let inviteRef = ref.childByAppendingPath("notifications").childByAppendingPath(receiverId).childByAutoId()
        inviteRef.setValue(["type": "invite", "uid": ref.authData.uid, "group": groupName])
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
