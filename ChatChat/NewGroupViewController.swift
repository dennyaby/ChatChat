//
//  NewGroupViewController.swift
//  ChatChat
//
//  Created by Admin on 17.04.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class NewGroupViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var stateLabel: UILabel!
    
    var ref = Firebase(url: "https://blinding-inferno-500.firebaseio.com/")
    
    var groups = [String]()
    
    var helper = Helper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let groupsRef = ref.childByAppendingPath("groups")
        groupsRef.observeEventType(.ChildAdded, withBlock: {snapshot in
            guard let groupName = snapshot.value["name"] as! String? else {
                return
            }
            self.groups.append(groupName)
        })
    }
    
    @IBAction func donePressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addGroup() {
        let groupName = textField.text! as String
        for group in groups {
            if group == groupName {
                stateLabel.text = "Group with this name already exists!"
                stateLabel.textColor = UIColor.redColor()
                performSelector(#selector(self.clearLabel), withObject: nil, afterDelay: 2)
                return
            }
        }
        
        let groupRef = ref.childByAppendingPath("groups").childByAutoId()
        groupRef.setValue(["name": groupName, "admin": ref.authData.uid])
        
        stateLabel.text = "Successfuly added"
        stateLabel.textColor = UIColor.greenColor()
        textField.text = ""
        performSelector(#selector(self.dismissWindow), withObject: nil, afterDelay: 2)
    }
    
    func clearLabel() {
        stateLabel.text = ""
    }
    
    func dismissWindow() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
