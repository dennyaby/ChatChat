//
//  BotChatViewController.swift
//  ChatChat
//
//  Created by Admin on 22.04.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation
import Firebase
import JSQMessagesViewController

class BotChatViewController: JSQMessagesViewController {
    
    var botName: String! = nil
    var bot: Bot!
    
    var messages = [JSQMessage]()
    
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        messages.append(JSQMessage(senderId: "user", senderDisplayName: self.senderDisplayName, date: date, text: text))
        self.finishSendingMessage()
        scrollToBottomAnimated(true)
        
        let botAnswer = bot.refactorInput(text)
        if let botAnswer = botAnswer {
            messages.append(JSQMessage(senderId: "bot", senderDisplayName: "bot", date: date, text: botAnswer))
            self.collectionView.reloadData()
        }
        
        setupBubbles()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch botName! {
        case "cityBot":
            bot = BotCityGame()
        default:
            bot = BotCityGame()
        }
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImage = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImage = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return outgoingBubbleImage
        } else  {
            return incomingBubbleImage
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
}
