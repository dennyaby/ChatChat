//
//  ContactCell.swift
//  ChatChat
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    var date: String! {
        didSet {
            dateLabel.text = date
        }
    }
    
    var message: String! {
        didSet {
            messageLabel.text = message
        }
    }
    
    var username: String! {
        didSet {
            usernameLabel.text = username
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!


}

