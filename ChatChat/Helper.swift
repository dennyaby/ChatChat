//
//  Helper.swift
//  ChatChat
//
//  Created by Admin on 31.03.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation
import Firebase

class Helper {
    var refUsers = Firebase(url: "https://blinding-inferno-500.firebaseio.com/users/")
    var refGroups = Firebase(url: "https://blinding-inferno-500.firebaseio.com/groups/")
    var users = [String: String]()
    var groups = [String: String]()
    
    init() {
        refUsers?.observeEventType(.ChildAdded, withBlock: {snapshot in
            if !(snapshot.value is NSNull) {
                let mail = snapshot.value["email"] as! String
                self.users[snapshot.key] = mail
            }
        })
        refGroups?.observeEventType(.ChildAdded, withBlock: {snapshot in
            if !(snapshot.value is NSNull) {
                let groupName = snapshot.value["name"] as! String
                self.groups[snapshot.key] = groupName
            }
        })
    }
    
    func getMailWithUid(uid: String) -> String? {
        if let value = users[uid] {
            return value
        } else {
            return nil
        }
    }
    
    func getUidWithMail(mail: String) -> String? {
        for (key, value) in users {
            if value == mail {
                return key
            }
        }
        return nil
    }
    
    func getUidWithGroupName(name: String) -> String? {
        for (key, value) in groups {
            if value == name {
                return key
            }
        }
        return nil
    }
    
}