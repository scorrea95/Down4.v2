//
//  settingsVC.swift
//  Down4
//
//  Created by amrun on 08/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import MessageUI
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import UserNotifications
import KVNProgress

class settingsVC: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var myswitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            self.myswitch.isOn = true
            
        }else{
            self.myswitch.isOn = false
        }
        
    }
    
    @IBAction func switchPressed(_ sender: Any) {
        if myswitch.isOn {
            UIApplication.shared.unregisterForRemoteNotifications()
            myswitch.isOn = false
        } else {
            notificationPermission()
            myswitch.isOn = true
            
        }
    }
    
    func notificationPermission() {
        if #available(iOS 10.0, *) {
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            KVNProgress.show()
            Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/notiToken").setValue("") //set notification token to empty string
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                try! Auth.auth().signOut()
                FBSDKAccessToken.setCurrent(nil)  //facebook
  
                self.performSegue(withIdentifier: "unwindToLogin", sender: self)
                KVNProgress.dismiss()
            }

        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            
            return 1
        }else if section == 1 {
            
            return 1
        }else if section == 2 {
            
            return 3
        }else {
            
            return 0
        }
        
    }
    
    @IBAction func termsPressed(_ sender: UIButton){
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "termsNav")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func privacyPressed(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "privacyNav")
        self.present(vc, animated: true, completion: nil)
    }
    
    //Send Feedback
    @IBAction func btnEmailTapped(_ sender: UIButton)
    {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else
        {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(["support@down4app.com"])
        mailComposerVC.setSubject("Feedback")
        mailComposerVC.setMessageBody("Feedback", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert()
    {
        let alert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {}
    
}

extension MFMailComposeViewController {
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        navigationBar.isOpaque = false
        navigationBar.barTintColor = UIColor.white
        navigationBar.tintColor = UIColor.white
    }
}
