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
    
    let logginInMessage = "You are not logged in."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Alamofire.request(.POST, myWordPressSite, parameters: ["check_login": 1])
            .responseJSON { request, response, json, error in
                
                if(error != nil) {
                    
                    NSLog("Error: \(error)")
                    
                }else{
                    
                    if json != nil{ //Make sure the retrieved JSON object is not empty
                        
                        //cast the retrieved json as a SwiftyJSON object
                        var json = JSON(json!)
                        
                        //Check if we're not logged in...
                        if let loggedIn = json["logged_in"].int{
                            
                            if loggedIn == 0{
                                self.loginMessage.text = self.logginInMessage
                                self.proceedButton.hidden = false
                            }
                            
                        }else{
                            
                            /* If we are logged in.
                             * If yes, display welcome message
                             */
                            
                            if json["data"]["display_name"] != nil{
                                if let name = json["data"]["display_name"].string{
                                    self.welcomeMessage(name)
                                }
                            }
                        }
                    }
                }
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
            popoverController.sourceView = sender as! UIView
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
        }
        
        presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .FullScreen
    }
    
    func presentationController(controller: UIPresentationController!, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController!?{
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
    
    func welcomeMessage(name:String){
        self.loginMessage.text = "Welcome back \(name)!"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

