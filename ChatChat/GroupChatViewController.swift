//
//  GroupChatViewController.swift
//  ChatChat
//
//  Created by Admin on 17.04.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController
import Firebase

class GroupChatViewController: JSQMessagesViewController {
    
    var selfEmail: String?
    var selfUid: String?
    var groupName: String?
    var admin: Bool?
    var groupId: String!

    let ref = Firebase(url: "https://blinding-inferno-500.firebaseio.com")
    var refMessages: Firebase!
    
    var messages = [JSQMessage]()
    
    let helper = Helper()
    
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let database = Database.sharedInstance
        
        selfEmail = ref.authData.providerData["email"] as? String
        
        groupId = database.getUidWithGroupName(groupName!)
        
        print(groupId)
        
        refMessages = ref.childByAppendingPath("groups").childByAppendingPath(groupId).childByAppendingPath("messages")
        
        refMessages.observeEventType(.ChildAdded, withBlock: { snapshot in
            let stringDate = snapshot.value["date"] as! String
            let text = snapshot.value["text"] as! String
            let senderUid = snapshot.value["uid"] as! String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
            let date = dateFormatter.dateFromString(stringDate)
            
            self.messages.append(JSQMessage(senderId: senderUid, senderDisplayName: self.helper.getMailWithUid(senderUid), date: date, text: text))
            self.messages = self.sortArrayByDate(self.messages)
            self.collectionView.reloadData()

        })
        
        setupBubbles()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        self.parentViewController?.navigationItem.title = selfEmail
        self.parentViewController?.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]

        if admin! {
            let setupButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(self.setupGroup))
            setupButton.tintColor = UIColor.whiteColor()
            self.navigationItem.rightBarButtonItem = setupButton
        } else {
            let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.inviteUser))
            addButton.tintColor = UIColor.whiteColor()
            self.navigationItem.rightBarButtonItem = addButton
        }
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottomAnimated(true)
    }
    
    
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImage = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImage = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
        let _date = dateFormatter.stringFromDate(date)
        
        let dict = ["uid": senderId, "text": text, "date": _date]
        
        refMessages.childByAutoId().setValue(dict)
        print(String(date))
        self.finishSendingMessage()
        
        scrollToBottomAnimated(true)
    }
    
    
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let currentMessage = messages[indexPath.item]
        
        if (indexPath.item - 1 >= 0) {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    
    
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return outgoingBubbleImage
        } else  {
            return incomingBubbleImage
        }
    }

    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.cellTopLabel.text = message.senderDisplayName
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.cellTopLabel.text = message.senderDisplayName
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    
    
    func inviteUser() {
        performSegueWithIdentifier("ChooseContact", sender: self)
    }
    
    func setupGroup() {
        performSegueWithIdentifier("AdminSettings", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AdminSettings" {
            let navVc = segue.destinationViewController as! UINavigationController
            let adminSettingsVc = navVc.viewControllers.first as! AdminSettingsViewController
            adminSettingsVc.groupName = groupName
        }
    }
    
    func sortArrayByDate(array:[JSQMessage]) -> [JSQMessage] {
        let sortedArray = array.sort({(first: JSQMessage, second: JSQMessage) -> Bool in
            return first.date.timeIntervalSince1970 < second.date.timeIntervalSince1970
        })
        return sortedArray
    }
}
