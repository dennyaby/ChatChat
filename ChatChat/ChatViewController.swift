/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController: JSQMessagesViewController {
    
    var email: String?
    var selfUid: String?
    var uid: String?
    
    var ref: Firebase!
    var refUsers: Firebase!
    var refMessageOut: Firebase!
    var refMessageIn: Firebase!
    var refMessageToSender: Firebase!
    var messages = [JSQMessage]()
    var inMessages = [String]()
    var outMessages = [String]()
    var contactSenderUniqueKey = ""
    var contactReceiverUniqueKey = ""
    
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    
    let helper = Helper()
    
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ref = Firebase(url: "https://blinding-inferno-500.firebaseio.com/")
    refUsers = ref.childByAppendingPath("users")
    
    selfUid = ref.authData.uid
    refMessageIn = ref.childByAppendingPath("messages").childByAppendingPath("to").childByAppendingPath(selfUid!)
    refMessageOut = ref.childByAppendingPath("messages").childByAppendingPath("from").childByAppendingPath(selfUid!)
    refMessageToSender = ref.childByAppendingPath("messages").childByAppendingPath("to").childByAppendingPath(uid!)
    
    refUsers.observeEventType(.ChildAdded, withBlock: {snapshot in
        if !(snapshot.value is NSNull) {
            let mail = snapshot.value["email"] as! String
            if mail == self.email {
                self.uid = snapshot.key

                print("Uid is\(self.uid)")
                print("selfUid is\(self.selfUid)")
                
                self.refMessageIn.observeEventType(.ChildAdded, withBlock: {snapshot in
                    if !(snapshot.value is NSNull) {
                        let id = snapshot.value["uid"] as! String
                        if id == self.uid {
                            print("in Message")
                            
                            let stringDate = snapshot.value["date"] as! String
                            let text = snapshot.value["text"] as! String
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
                            let date = dateFormatter.dateFromString(stringDate)
                        
                            self.messages.append(JSQMessage(senderId: self.uid, senderDisplayName: "Lo lo lo", date: date, text: text))
                            self.messages = self.sortArrayByDate(self.messages)
                            self.collectionView.reloadData()
                        }
                    }
                })
                
                self.refMessageOut.observeEventType(.ChildAdded, withBlock: {snapshot in
                    if !(snapshot.value is NSNull) {
                        let id = snapshot.value["uid"] as! String
                        if id ==  self.uid {
                            print("out Message")
                            
                            let stringDate = snapshot.value["date"] as! String
                            let text = snapshot.value["text"] as! String
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
                            let date = dateFormatter.dateFromString(stringDate)
                        
                            self.messages.append(JSQMessage(senderId: self.selfUid, senderDisplayName: self.senderDisplayName, date: date, text: text))
                            self.messages = self.sortArrayByDate(self.messages)
                            self.collectionView.reloadData()
                        }
                    }
                })
            }
        }
        
    })
    
    let contactsSenderRef = ref!.childByAppendingPath("users").childByAppendingPath(ref!.authData.uid).childByAppendingPath("contacts")

    contactsSenderRef.observeEventType(.ChildAdded, withBlock: { snapshot in
        if snapshot.value["mail"] as? String == self.email {
            self.contactSenderUniqueKey = snapshot.key
        }
    })
    
    let contactsReceiverRef = ref!.childByAppendingPath("users").childByAppendingPath(uid!).childByAppendingPath("contacts")
    contactsReceiverRef.observeEventType(.ChildAdded, withBlock:  { snapshot in
        if snapshot.value["mail"] as? String == self.ref.authData.providerData["email"] as? String {
            self.contactReceiverUniqueKey = snapshot.key
        }
    })

    
    setupBubbles()
    collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
    collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    
    UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    
  }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let itemIn = refMessageToSender.childByAutoId()
        let itemOut = refMessageOut.childByAutoId()
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
        let _date = dateFormatter.stringFromDate(date)
        
        let messageIn = ["text" : text, "date" : _date, "uid": self.selfUid]
        let messageOut = ["text" : text, "date" : _date, "uid": self.uid]
        
        itemIn.setValue(messageIn)
        itemOut.setValue(messageOut)
        
        if contactSenderUniqueKey != "" {
            let lastSenderMessageRef = ref.childByAppendingPath("users").childByAppendingPath(ref!.authData.uid).childByAppendingPath("contacts").childByAppendingPath(contactSenderUniqueKey).childByAppendingPath("lastMessage")
            let lastMessageValue = ["text": text, "date": _date]
            lastSenderMessageRef.setValue(lastMessageValue)
        }
        
        if contactReceiverUniqueKey != "" {
            let lastReceiverMessageRef = ref.childByAppendingPath("users").childByAppendingPath(uid).childByAppendingPath("contacts").childByAppendingPath(contactReceiverUniqueKey).childByAppendingPath("lastMessage")
            let lastMessageValue = ["text": text, "date": _date]
            lastReceiverMessageRef.setValue(lastMessageValue)
        }
        
        
        print(String(date))
        self.finishSendingMessage()
        
        scrollToBottomAnimated(true)
    }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottomAnimated(true)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.cellTopLabel.text = ref.authData.providerData["email"] as? String
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.cellTopLabel.text = email
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: email, text: text)
        messages.append(message)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    

    
    func sortArrayByDate(array:[JSQMessage]) -> [JSQMessage] {
        let sortedArray = array.sort({(first: JSQMessage, second: JSQMessage) -> Bool in
            return first.date.timeIntervalSince1970 < second.date.timeIntervalSince1970
        })
        return sortedArray
    }
  
}