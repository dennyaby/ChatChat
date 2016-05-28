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
import Firebase

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    var ref: Firebase!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ref = Firebase(url: "https://blinding-inferno-500.firebaseio.com")
  }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoginAnonimously" {
            let navVc = segue.destinationViewController as! UINavigationController
            let tabBarVc = navVc.viewControllers.first as! UITabBarController
            tabBarVc.navigationItem.title = "Anonim"
        }
        
        if segue.identifier == "Login" {
            /*let navVc = segue.destinationViewController as! UINavigationController
            let tabBarVc = navVc.viewControllers.first as! UITabBarController
            let contantsVc = tabBarVc.viewControllers!.first as! ContactsViewController
            contactsNavVc.title = "My my my"
            let stringse = ref.authData.providerData["email"] as? String*/
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func loginInChat() {
        self.performSegueWithIdentifier("Login", sender: nil)
    }
    
    @IBAction func login() {
        let email = emailField.text
        let password = passwordField.text
        self.ref.authUser(email, password: password,
                          withCompletionBlock: { (error, auth) -> Void in
                            if error == nil {
                                self.stateLabel.text = "Login Successful"
                                self.stateLabel.textColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
                                self.clearLabelWithDuration()
                                print("Loginned")
                                let selector = #selector(self.loginInChat)
                                self.performSelector(selector, withObject: self, afterDelay: 2)
                            } else {
                                self.stateLabel.text = "Cannot login"
                                self.stateLabel.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
                                self.clearLabelWithDuration()
                            }
        })
    }
    
    @IBAction func signUp() {
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default) { (action: UIAlertAction!) -> Void in
                                        
                                        let emailField = alert.textFields![0] 
                                        let passwordField = alert.textFields![1] 
                                        self.ref.createUser(emailField.text, password: passwordField.text) { (error: NSError!) in
                                            if error == nil {
                                                self.stateLabel.text = "Registration done"
                                                self.stateLabel.textColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
                                                self.clearLabelWithDuration()
       
                                                self.ref.authUser(emailField.text, password: passwordField.text,
                                                                  withCompletionBlock: { (error, auth) -> Void in
                                                                    print("New user \(emailField.text!) created!")
                                                                    if error == nil {
                                                                        let selector = #selector(self.loginInChat)
                                                                        self.performSelector(selector, withObject: self, afterDelay: 2)
                                                                        self.ref.childByAppendingPath("users").childByAppendingPath(self.ref.authData.uid).childByAppendingPath("email").setValue(emailField.text)
                                                                    }
                                                })
                                                
                                            }
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textEmail) -> Void in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textPassword) -> Void in
            textPassword.secureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
                              animated: true,
                              completion: nil)

    }
    
    @IBAction func cancelToLoginViewController(segue: UIStoryboardSegue){
        
    }
    
    func clearLabelWithDuration() {
        performSelector(#selector(self.clearLabel), withObject: nil, afterDelay: 2)
    }
    
    func clearLabel() {
        stateLabel.text = ""
    }
    
}

