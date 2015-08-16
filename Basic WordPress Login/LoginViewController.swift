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
    
    let messages:[Int:String] = [
        1:"Invalid username. Please try again.",
        2:"Invalid password. Please try again.",
    ]
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginToWordPress(sender: AnyObject) {
    
        if !username.text.isEmpty && !password.text.isEmpty
        {
            Alamofire.request(.POST, myWordPressSite, parameters: [
                "check_login": 2,
                "ios_userlogin":username.text,
                "ios_userpassword":password.text
                ]).responseJSON { request, response, json, error in
                    
                    if(error != nil) {
                        NSLog("Error: \(error)")
                    }else{
                        if json != nil
                        {
                            var json = JSON(json!)
                            
                            if json["error"] != nil{
                                //Alert error messages
                                if let error = json["error"].int{
                                    self.loginAlert(self.messages[error]!)
                                }
                            }else{
                                
                                if json["data"]["display_name"] != nil{
                                    if let name = json["data"]["display_name"].string{
                                        
                                        //Pass display name to delegate's "sendUser" method
                                        self.delegate?.sendUser(name)
                                        
                                        //Return to parent
                                        self.dismissViewControllerAnimated(true, completion: {
                                            action in
                                        })

                                    }
                                }
                            }
                        }
                    }
                    
                }
        }
    }
    
    func loginAlert(alertMessage: String)
    {
        var loginAlert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        loginAlert.addAction(okAction)
        
        self.presentViewController(loginAlert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
