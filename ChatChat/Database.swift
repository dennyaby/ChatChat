//
//  Database.swift
//  ChatChat
//
//  Created by Admin on 16.04.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Database {
    
    static let sharedInstance = Database()
    
    var authDeleage: Authentification?
    var contactDelegate: ContactList?
    var uid: String?
    var ref = Firebase(url: "https://blinding-inferno-500.firebaseio.com");
    var contactsRef:Firebase?
    var usersRef:Firebase?
    var notificationRef = Firebase(url: "https://blinding-inferno-500.firebaseio.com/notifications")
    var refGroups = Firebase(url: "https://blinding-inferno-500.firebaseio.com/groups/")
    
    var email: String?

    var contacts = [String: String]()
    var users = Set<String>()

    var emailUid = [String: String]()
    
    var groupName: String?
    
    var groups = [String: String]()
    
    init() {
        let str = " assda"
        let chars = str.characters
        for ch in chars {
            print(ch)
        }
        ref.childByAppendingPath("users").observeEventType(.ChildAdded, withBlock: {snapshot in
            if !(snapshot.value is NSNull) {
                let mail = snapshot.value["email"] as! String
                self.emailUid[snapshot.key] = mail
            }
        })
        
        refGroups?.observeEventType(.ChildAdded, withBlock: {snapshot in
            if !(snapshot.value is NSNull) {
                let groupName = snapshot.value["name"] as! String
                self.groups[snapshot.key] = groupName
            }
        })

    }
    
    func getUidWithGroupName(name: String) -> String? {
        print(groups.count)
        for (key, value) in groups {
            if value == name {
                return key
            }
        }
        return nil
    }
    
    func getGroupName() -> String {
        return groupName!
    }
    
    func authUser(username username: String, password: String) {
        ref.authUser(username, password: password,
                          withCompletionBlock: { (error, auth) -> Void in
                            if error == nil {
                                self.uid = self.ref.authData.providerData["uid"] as? String
                                self.email = self.ref.authData.providerData["email"] as? String
                                self.addObserverToUsers()
                                
                                self.authDeleage?.loginSuccessful()
                            } else {
                                self.authDeleage?.loginFailed()
                            }
        })

    }
    
    func createUser(username username: String, password: String) {
        ref.createUser(username, password: password) { (error: NSError!) in
            if error == nil {
                self.ref.childByAppendingPath("users").childByAppendingPath(self.ref.authData.uid).childByAppendingPath("email").setValue(username)
                self.authDeleage?.registerSuccesful()
            } else {
                self.authDeleage?.registerFailed()
            }
        }
    }
    
    func addNewContact(email: String) {
        let numberString = String(contacts.count + 1)
        contactsRef!.childByAppendingPath(numberString).childByAppendingPath("mail").setValue(email)
        contactsRef!.childByAppendingPath(numberString).childByAppendingPath("lastMessage").childByAppendingPath("text").setValue("")
    }
    
    func sendNotificationOfType(type: String, receiver: String) {
        let receiver = notificationRef.childByAppendingPath(receiver).childByAutoId()
        receiver.childByAppendingPath("type").setValue(type)
        receiver.childByAppendingPath("uid").setValue(ref!.authData.uid)
    }
    
    func unAuth() {
        
        removeObserverToContacts()
        removeObserverToUsers()
        cleanContactsData()
        cleanUsersData()
        
        ref.unauth()
    }
    
    func getMailWithUid(uid: String) -> String? {
        if let value = emailUid[uid] {
            return value
        } else {
            return nil
        }
    }
    
    func getUidWithMail(mail: String) -> String? {
        for (key, value) in emailUid {
            if value == mail {
                return key
            }
        }
        return nil
    }
    
    func getContacts() -> [String: String] {
        return contacts
    }
    
    func getUsers() -> [String] {
        var myUsers = [String]()
        for user in users {
            myUsers.append(user)
        }
        
        return myUsers
    }
    
    func cleanContactsData() {
        contacts.removeAll()
    }
    
    func cleanUsersData() {
        users.removeAll()
    }
    
    func addObserverToContacts() {
        contactsRef = ref!.childByAppendingPath("users").childByAppendingPath(ref!.authData.uid).childByAppendingPath("contacts")
        contactsRef!.observeEventType(.ChildAdded, withBlock: {snapshot in
            if !(snapshot.value is NSNull) {
                self.contacts[snapshot.key] = snapshot.value["mail"] as? String
                print("\(snapshot.key) : \(snapshot.value as? String)")
                print(self.contacts)
                self.contactDelegate?.contactListUpdated()
            }
        })
    }
    
    func addObserverToUsers() {
        usersRef = ref?.childByAppendingPath("users")
        usersRef?.observeEventType(.ChildAdded, withBlock: {snapshot in
            if !(snapshot.value is NSNull) {
                let mail = snapshot.value["email"] as! String
                if mail != (self.ref?.authData.providerData["email"] as! String) {
                    self.users.insert(mail)
                }
            }
        })
    }
    
    func removeObserverToContacts() {
        contactsRef?.removeAllObservers()
    }
    
    func removeObserverToUsers() {
        usersRef?.removeAllObservers()
    }
    
}

protocol Authentification {
    func loginSuccessful()
    func loginFailed()
    
    func registerSuccesful()
    func registerFailed()
}

protocol ContactList {
    func contactListUpdated()
}
