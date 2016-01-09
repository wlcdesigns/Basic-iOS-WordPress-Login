//
//  LoginViewController.swift
//  Basic WordPress Login
//
//  Created by wlc on 8/11/15.
//  Copyright (c) 2015 wLc Designs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

//Create a delegate for the LoginViewController
protocol LoginViewControllerDelegate{
    func sendUser(name : String)
}

class LoginViewController: UIViewController {
    
    //inititalize the delegate
    var delegate:LoginViewControllerDelegate!

    lazy var json : JSON = JSON.null
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginToWordPress(sender: AnyObject) {
        
        if !username.text!.isEmpty && !password.text!.isEmpty{
            remoteLogin(username.text!, password: password.text!)
        }
    }
    
    func remoteLogin(user: String, password: String)
    {
        Alamofire.request(.POST, myWordPressSite, parameters: [
            "check_login": 2,
            "ios_userlogin":user,
            "ios_userpassword":password
            ]).responseJSON { response in
                
                //Check if response is valid and not empty
                guard let data = response.result.value else{
                    self.loginAlert("Login Failed")
                    return
                }
                
                //Convert data response to json object
                self.json = JSON(data)
                
                //Check for serverside login errors
                guard self.json["error"] == nil else{
                    
                    switch(self.json["error"])
                    {
                    case 1:
                        self.loginAlert("Invalid Username")
                        
                    case 2:
                        self.loginAlert("Invalid Password")
                        
                    default:
                        self.loginAlert("Login Failure")
                    }
                    
                    return
                }
                
                //Return to homescreen with welcome message
                guard let name = self.json["data"]["display_name"].string else{
                    return
                }
                
                self.delegate?.sendUser(name)
                
                self.dismissViewControllerAnimated(true, completion: {
                    action in
                })
        }
    }
    
    func loginAlert(alertMessage: String)
    {
        let loginAlert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        loginAlert.addAction(okAction)
        
        self.presentViewController(loginAlert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
