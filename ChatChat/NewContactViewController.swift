//
//  NewContactViewController.swift
//  ChatChat
//
//  Created by Admin on 28.03.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase

class NewContactViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var stateLabel: UILabel!
    
    var users = Set<String>()
    var ref: Firebase?
    var refContacts: Firebase?
    var refUsers: Firebase?
    var notificationRef = Firebase(url: "https://blinding-inferno-500.firebaseio.com/notifications")
    
    var helper = Helper()

    var contacts = [String: String]()
    var bots = [String]()
    var myBots = [String]()
    
    @IBAction func addContact() {
        print(bots)
        let text = emailField.text
        for botName in bots {
            if text == botName {
                if myBots.contains(botName) {
                    stateLabel.text = "Bot already exists!"
                    stateLabel.textColor = UIColor.redColor()
                    self.performSelector(#selector(self.clearLabel), withObject: self, afterDelay: 2)
                    return
                } else {
                    let botsRef = ref?.childByAppendingPath("users").childByAppendingPath(ref!.authData.uid).childByAppendingPath("bots")
                    botsRef?.childByAutoId().setValue(botName)
                    stateLabel.text = "Bot added!"
                    stateLabel.textColor = UIColor.greenColor()
                    self.performSelector(#selector(self.clearLabel), withObject: self, afterDelay: 2)
                    return
                }
            }
        }
        for value in contacts.values {
            if users.contains(value) {
                users.remove(value)
                if value == text {
                    stateLabel.text = "Exists in your contacts!"
                    stateLabel.textColor = UIColor.redColor()
                    self.performSelector(#selector(self.clearLabel), withObject: self, afterDelay: 2)
                    return
                }
            }
        }
        if refContacts != nil {
            if users.contains(text!) {
                stateLabel.text = "Invitation send!"
                stateLabel.textColor = UIColor.greenColor()
                
                let receiverId = helper.getUidWithMail(text!)
                let receiver = notificationRef.childByAppendingPath(receiverId).childByAutoId()
                receiver.setValue(["type": "add", "uid" : ref!.authData.uid])
                //receiver.childByAppendingPath("type").setValue("add")
                //receiver.childByAppendingPath("uid").setValue(ref!.authData.uid)
                
                self.emailField.text = ""
                
                self.performSelector(#selector(self.clearLabel), withObject: self, afterDelay: 2)
            } else {
                stateLabel.text = "Dont exists!"
                stateLabel.textColor = UIColor.redColor()
                self.performSelector(#selector(self.clearLabel), withObject: self, afterDelay: 2)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        ref = Firebase(url: "https://blinding-inferno-500.firebaseio.com/")
        
        refContacts = ref!.childByAppendingPath("users").childByAppendingPath(ref!.authData.uid).childByAppendingPath("contacts")
        refContacts!.observeEventType(.ChildAdded, withBlock: {snapshot in
            print("Observed contact")
            if !(snapshot.value is NSNull) {
                print("Assigned")
                self.contacts[snapshot.key] = snapshot.value["mail"] as? String
                print("\(snapshot.key) : \(snapshot.value as? String)")
            }
        })
        
        refUsers = ref?.childByAppendingPath("users")
        refUsers?.observeEventType(.ChildAdded, withBlock: {snapshot in
            if !(snapshot.value is NSNull) {
                let mail = snapshot.value["email"] as! String
                if mail != (self.ref?.authData.providerData["email"] as! String) {
                    self.users.insert(mail)
                    print(mail)
                }
            }
        })
        
        let botRef = ref?.childByAppendingPath("bots")
        botRef?.observeEventType(.ChildAdded, withBlock: { snapshot in
            let botName = snapshot.value as? String
            self.bots.append(botName!)
            
        })
        
        let myBotRef = ref?.childByAppendingPath("users").childByAppendingPath(ref!.authData.uid).childByAppendingPath("bots")
        myBotRef?.observeEventType(.ChildAdded, withBlock: {snapshot in
            let botName = snapshot.value as? String
            self.myBots.append(botName!)
        })

    }
    
    func clearLabel() {
        stateLabel.text = ""
    }
    
    
}
