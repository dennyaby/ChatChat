//
//  NotificationListener.swift
//  ChatChat
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation
import Firebase

class NotificationListener {
    
    var ref = Firebase(url: "https://blinding-inferno-500.firebaseio.com/notifications")
    var mainRef = Firebase(url: "https://blinding-inferno-500.firebaseio.com/")
    var refUsers = Firebase(url: "https://blinding-inferno-500.firebaseio.com/")
    var receiverId: String?
    let helper = Helper()
    weak var context: UIViewController?
    
    init(context: UIViewController, receiverId: String?) {
        
        self.receiverId = receiverId
        self.context = context
        ref.observeEventType(.ChildAdded, withBlock: {snapshot in
            print("notification ref")
            if let uid = self.receiverId {
                if snapshot.key == uid {
                    let rootDict = snapshot.value as! [String: AnyObject]
                    print(rootDict)
                    for (autoKey, value) in rootDict {
                        let dict = value as! [String: AnyObject]
                        guard let type = dict["type"] as? String else {
                            break
                        }
                        guard let uidSender = dict["uid"] as? String else {
                            break
                        }
                        
                        var mail = self.helper.getMailWithUid(dict["uid"] as! String)
                        if mail == nil {
                            mail = "Unknown"
                            continue
                        }
                        switch type {
                            case "add":
                                let alert = UIAlertController(title: "New Contact",
                                    message: "\(mail!) user want to add you to contact list!",
                                    preferredStyle: .Alert)
                                let acceptAction = UIAlertAction(title: "Accept", style: .Cancel) {(action: UIAlertAction!) -> Void in
                                    print("Accept")
                                    
                                    let tempRef = self.mainRef.childByAppendingPath("users").childByAppendingPath(uidSender).childByAppendingPath("contacts").childByAutoId()
                                    
                                    let receiverMail = self.helper.getMailWithUid(self.receiverId!)
                                    tempRef.childByAppendingPath("mail").setValue(receiverMail)
                                    tempRef.childByAppendingPath("lastMessage").childByAppendingPath("text").setValue("")
                                    
                                    let receiverTempRef = self.mainRef.childByAppendingPath("users").childByAppendingPath(receiverId).childByAppendingPath("contacts").childByAutoId()
                                    
                                    let senderMail = self.helper.getMailWithUid(uidSender)
                                    //receiverTempRef.childByAppendingPath("mail").setValue(senderMail)
                                    //receiverTempRef.childByAppendingPath("lastMessage").childByAppendingPath("text").setValue("")
                                    let dicti:[String: AnyObject] = ["mail": senderMail!, "lastMessage": ["text" : ""]]
                                    receiverTempRef.setValue(dicti)
                                    
                                    let senderRefNotification = self.ref.childByAppendingPath(uidSender).childByAutoId()
                                    senderRefNotification.setValue(["type": "accepted", "uid" : self.ref!.authData.uid])
                                    
                                    self.ref.childByAppendingPath(self.receiverId!).childByAppendingPath(autoKey).removeValue()
                                    
                                }
                                
                                let declineAction = UIAlertAction(title: "Decline", style: .Default) {(action: UIAlertAction!) -> Void in
                                    print("Decline")
                                    self.ref.childByAppendingPath(self.receiverId!).childByAppendingPath(autoKey).removeValue()
                                    
                                    let senderRefNotification = self.ref.childByAppendingPath(uidSender).childByAutoId()
                                    senderRefNotification.setValue(["type": "refused", "uid" : self.ref!.authData.uid])
                                }
                                alert.addAction(acceptAction)
                                alert.addAction(declineAction)
                                
                               self.context?.presentViewController(alert, animated: true, completion: nil)
                                
                                break
                            case "accepted":
                                let senderMail = self.helper.getMailWithUid(uidSender)
                                let alert = UIAlertController(title: "Accepted", message: "User \(senderMail!) accepted you friendship!", preferredStyle: .Alert)
                                let acceptAction = UIAlertAction(title: "Good!", style: .Default) {(action: UIAlertAction!) -> Void in
                                    self.ref.childByAppendingPath(self.receiverId).childByAppendingPath(autoKey).removeValue()
                                    let tableVc = context as! UITableViewController
                                    tableVc.tableView.reloadData()
                                }
                                alert.addAction(acceptAction)
                                
                                self.context?.presentViewController(alert, animated: true, completion: nil)
                                break
                            case "refused":
                                let senderMail = self.helper.getMailWithUid(uidSender)
                                let alert = UIAlertController(title: "Refused", message: "User \(senderMail!) refused you friendship!", preferredStyle: .Alert)
                                let refuseAction = UIAlertAction(title: "Okay!", style: .Destructive) {(action: UIAlertAction!) -> Void in
                                    self.ref.childByAppendingPath(self.receiverId).childByAppendingPath(autoKey).removeValue()
                                }
                                alert.addAction(refuseAction)
                                
                                self.context?.presentViewController(alert, animated: true, completion: nil)
                                break
                            case "invite":
                                guard let groupName = dict["group"] as? String else {
                                    break
                                }
                                let alert = UIAlertController(title: "Invite",
                                    message: "\(mail!) invites you in \(groupName)!",
                                    preferredStyle: .Alert)
                                let acceptAction = UIAlertAction(title: "Accept", style: .Cancel) {(action: UIAlertAction!) -> Void in
                                    print(self.helper.getUidWithGroupName(groupName))
                                    
                                    let groupRef = self.mainRef.childByAppendingPath("groups").childByAppendingPath(self.helper.getUidWithGroupName(groupName))
                                    groupRef.childByAppendingPath("users").childByAutoId().setValue(receiverId)
                                    
                                    self.ref.childByAppendingPath(self.receiverId!).childByAppendingPath(autoKey).removeValue()
                                    
                                }
                                
                                let declineAction = UIAlertAction(title: "Decline", style: .Default) {(action: UIAlertAction!) -> Void in
                                    print("Decline")
                                    self.ref.childByAppendingPath(self.receiverId!).childByAppendingPath(autoKey).removeValue()

                                }
                                alert.addAction(acceptAction)
                                alert.addAction(declineAction)
                                
                                self.context?.presentViewController(alert, animated: true, completion: nil)

                                break
                            case "delete":
                                break
                            case "removed":
                                break
                        default:
                            break
                        }
                        
                    }
                }
            }
        })
    }
}
