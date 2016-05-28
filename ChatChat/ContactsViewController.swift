//
//  ContactsViewController.swift
//  ChatChat
//
//  Created by Admin on 26.03.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Firebase
import UIKit

class ContactsViewController: UITableViewController {
    
    var ref: Firebase!
    var refContacts: Firebase!
    var refBots: Firebase!
    
    var uid: String?
    
    var contacts = [lastMessage]()
    var bots = [String]()

    var addButton: UIBarButtonItem?
    
    var firstTime = true
    
    var destinationEmail: String?
    var destinationBotName: String?
    
    var helper = Helper()
    
    var notificationListener: NotificationListener? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Firebase(url: "https://blinding-inferno-500.firebaseio.com/")
        uid = ref!.authData.uid
        initNotificationListener()
        refContacts = ref!.childByAppendingPath("users").childByAppendingPath(ref!.authData.uid).childByAppendingPath("contacts")
        refBots = ref!.childByAppendingPath("users").childByAppendingPath(ref!.authData.uid).childByAppendingPath("bots")
        
        self.title = "Contacts"
        addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addContact))
        addButton!.tintColor = UIColor.whiteColor()
        self.parentViewController?.navigationItem.title = ref.authData.providerData["email"] as? String
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        self.parentViewController?.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    func sortContacts() {
        contacts = contacts.sort({(message1: lastMessage, message2: lastMessage) -> Bool in
            if message1.text == ""  { return false }
            if message2.text == ""  { return true  }
            
            return message1.date!.timeIntervalSince1970 > message2.date!.timeIntervalSince1970
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.parentViewController!.navigationItem.rightBarButtonItem = addButton
        addObservers()
    }
    
    func addObservers() {
        refContacts.observeEventType(.ChildAdded, withBlock: {snapshot in
            if !(snapshot.value is NSNull) {
                if self.firstTime {
                    self.firstTime = false
                }
                let email = snapshot.value["mail"] as? String
                let lastMessageDict = snapshot.value["lastMessage"] as? [String: AnyObject]
                let lastMessageText = lastMessageDict!["text"] as? String
                
                if (lastMessageText == "") {
                    self.contacts.append(lastMessage(date: nil, text: lastMessageText!, email: email))
                } else {
                    let lastMessageDate = lastMessageDict!["date"] as? String
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
                    let date = dateFormatter.dateFromString(lastMessageDate!)
                    self.contacts.append(lastMessage(date: date!, text: lastMessageText!, email: email!))
                }
                
                self.sortContacts()
                self.tableView.reloadData()
            }
        })
        
        refBots.observeEventType(.ChildAdded, withBlock: { snapshot in
            let botName = snapshot.value as? String
            if !self.bots.contains(botName!) {
                self.bots.append(botName!)
                self.tableView.reloadData()
            }
        })
    }
    
    func removeObservers() {
        refContacts.removeAllObservers()
        refBots.removeAllObservers()
    }
    
    func clearData() {
        contacts.removeAll()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.parentViewController!.navigationItem.rightBarButtonItem = nil
        removeObservers()
        clearData()
    }

    @IBAction func addContact() {
        self.performSegueWithIdentifier("NewContact", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OpenChat" {
            let chatVc = segue.destinationViewController as! ChatViewController
            chatVc.senderId = ref.authData.uid
            chatVc.senderDisplayName = ref.authData.providerData["email"] as! String
            chatVc.navigationItem.title = destinationEmail
            chatVc.email = destinationEmail
            chatVc.uid = helper.getUidWithMail(destinationEmail!)
        } else if segue.identifier == "NewContact" {

        } else if segue.identifier == "OpenBotChat" {
            let chatVc = segue.destinationViewController as! BotChatViewController
            chatVc.senderId = "user"
            chatVc.senderDisplayName = ref.authData.providerData["email"] as! String
            chatVc.navigationItem.title = destinationBotName
            chatVc.botName = destinationBotName
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if bots.count > 0 && contacts.count > 0 {
            return 2
        } else if bots.count == 0 && contacts.count == 0 {
            return 0
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && contacts.count > 0 {
            return contacts.count
        } else if section == 0 && contacts.count == 0 {
            return bots.count
        } else {
            return bots.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print(bots)
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactsCell", forIndexPath: indexPath) as! ContactCell
            let lastMessage = contacts[indexPath.item]
            cell.username = lastMessage.email
            if lastMessage.text != "" {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd.MM.yy"
                let date = dateFormatter.stringFromDate(lastMessage.date!)
                cell.date = date

                cell.message = lastMessage.text
            } else {
                cell.message = "No messages"
                cell.date = ""
            }
        
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("BotsCell", forIndexPath: indexPath)
            cell.textLabel!.text = bots[indexPath.item]
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            self.destinationEmail = contacts[indexPath.item].email
            self.performSegueWithIdentifier("OpenChat", sender: nil)
        } else {
            self.destinationBotName = bots[indexPath.item]
            self.performSegueWithIdentifier("OpenBotChat", sender: nil)
        }
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && contacts.count > 0{
            return "Contacts"
        } else if section == 0 {
            return "Bots"
        } else if section == 1{
            return "Bots"
        } else {
            return nil
        }
    }
    
    @IBAction func savePlayerDetail(segue: UIStoryboardSegue) {
     
    }
    
    @IBAction func cancelToPlayersViewController(segue: UIStoryboardSegue){
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func initNotificationListener() {
        notificationListener = NotificationListener(context: self, receiverId: uid)
    }
    
    
}

struct lastMessage {
    var date: NSDate?
    var text: String
    var email: String?
}
