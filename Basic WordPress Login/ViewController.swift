//
//  ViewController.swift
//  Basic WordPress Login
//
//  Created by wlc on 8/11/15.
//  Copyright (c) 2015 wLc Designs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, LoginViewControllerDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var loginMessage: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    lazy var json : JSON = JSON.null
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLogin()
    }
    
    func checkLogin()
    {
        Alamofire.request(.POST, myWordPressSite, parameters: ["check_login": 1])
            .responseJSON { response in
                
                //Check if response is valid and not empty
                guard let data = response.result.value else{
                    self.loginMessage.text = "Request failed"
                    return
                }
                
                //Convert data response to json object
                self.json = JSON(data)
                
                //Check if logged in
                guard self.json["logged_in"] != 0 else{
                    
                    self.loginMessage.text = "You are not logged in."
                    self.proceedButton.hidden = false
                    
                    return
                }
                
                //If logged in, return welcome message
                guard let name = self.json["data"]["display_name"].string else{
                    return
                }
                
                self.logoutButton.hidden = false
                self.welcomeMessage(name)
                
        }
    }
    
    /* Required method LoginViewControllerDelegate
     * This method returns a welcome message from the LoginViewController
     */
    func sendUser(name : String){
        //self.loginMessage.text = "Welcome back \(name)!"
        self.welcomeMessage(name)
        self.proceedButton.hidden = true
    }
    
    @IBAction func goLogin(sender: AnyObject) {
    
        //Set up the PopOver segue for the LoginViewController
        let loginViewController = storyboard?.instantiateViewControllerWithIdentifier("LoginPopOverVC") as! LoginViewController
        
        loginViewController.delegate = self;
        loginViewController.modalPresentationStyle = .Popover
        
        if let popoverController = loginViewController.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
        }
        
        presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .FullScreen
    }

    func welcomeMessage(name:String){
        self.loginMessage.text = "Welcome back \(name)!"
        
        //Show Logout Button upon succesful login
        self.logoutButton.hidden = false
    }
    
    
    @IBAction func logOut(sender: AnyObject) {
        
        Alamofire.request(.POST, myWordPressSite, parameters: ["check_login": 3])
            .responseJSON { response in
            
            self.loginMessage.text = "You are not logged in."
            self.proceedButton.hidden = false
            self.logoutButton.hidden = true
 
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

