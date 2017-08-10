//
//  loginVC.swift
//  Down4
//
//  Created by amrun on 02/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import KVNProgress

class loginVC: UIViewController {
    
    var backgroundImageNames: [String]?
    var introductionView: ZWIntroductionViewController?

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var forgotPassword: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.attributedPlaceholder = NSAttributedString(string:"Email",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.white])
        passwordField.attributedPlaceholder = NSAttributedString(string:"Password",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        loginButton.layer.cornerRadius = 13
        loginButton.layer.masksToBounds = true
        loginButton.addTarget(self, action:#selector(self.loginPressed), for: .touchUpInside)
        
        fbButton.layer.cornerRadius = 13
        fbButton.layer.masksToBounds = true
        fbButton.addTarget(self, action:#selector(self.FBsignIN), for: .touchUpInside)
        
        isAppAlreadyLaunchedOnce()
    }

    func loginPressed() {
        
        KVNProgress.show()
        
        if requiredFieldsAreNotEmpty() {
            
            Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: {
                user, error in
                
                if error == nil {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.updateUIElements()
                        KVNProgress.dismiss()
                    }
                    
                } else {
                    
                    KVNProgress.dismiss()
                    
                    let alert = UIAlertController(title: "Alert!", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            
            KVNProgress.dismiss() //indicator dismiss
            
            let alert = UIAlertController(title: "Empty Field", message: "Please enter an email and password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func FBsignIN() {
        let facebookLogin = FBSDKLoginManager()
        
        print("Logging In")
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self, handler:{(facebookResult, facebookError) -> Void in
            
            if facebookError != nil {
                
                print("Facebook login failed.Error \(facebookError!)")
                KVNProgress.dismiss()
                let alert = UIAlertController(title: "Alert!", message: "\(facebookError!)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
                
            else if (facebookResult?.isCancelled)! {
                
                print("Facebook login was cancelled.")
                KVNProgress.dismiss()
            }
                
            else {
                print("You’re in")
                KVNProgress.dismiss()
                
                let accessToken = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                Auth.auth().signIn(with: accessToken) { (user, error) in
                    
                    if error != nil {
                        print("Login Failed, \(error!)")
                        KVNProgress.dismiss()
                        let alert = UIAlertController(title: "Alert!", message: "\(error!)", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }else {
                        KVNProgress.show()
                        print("Logged in! \(user!)")
                        
                        self.checkIfUserExists(user!, completionHandler: { (exists) in
                            
                            if(exists){
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.updateUIElements()
                                    KVNProgress.dismiss()
                                }
                            }else{
                                
                                let params: [String : Any] = ["redirect": false, "height": 400, "width": 400, "type": "large"]
                                let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture", parameters: params, httpMethod: "GET")
                                pictureRequest?.start(completionHandler: {
                                    (connection, result, error) -> Void in
                                    if error == nil {
                                        print("\(result!)")
                                        
                                        let dictionary = result as? [String:Any]
                                        let dataDic = dictionary?["data"] as? [String:Any]
                                        let urlPic = dataDic?["url"] as? String
                                        
                                        userModel.imageURL = urlPic!
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            
                                            KVNProgress.dismiss()
                                            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                            let vc = storyboard.instantiateViewController(withIdentifier: "enterdetailnav") as! UINavigationController
                                            vc.modalPresentationStyle = .custom
                                            vc.modalTransitionStyle = .crossDissolve
                                            self.present(vc, animated: true, completion: nil)
                                        }
                                        
                                    } else {
                                        print("\(error)")
                                        KVNProgress.dismiss()
                                        let alert = UIAlertController(title: "Alert!", message: "\(error!)", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }
                                })
                                
                                userModel.fullName = user!.displayName! as String
                                userModel.email = user!.email! as String
//                              donorModel.imageURL = user!.photoURL!.absoluteString as String
                                userModel.uid = user!.uid as String
                            }
                        })
                    }
                }
            }
        });

    }
    
    func requiredFieldsAreNotEmpty() -> Bool {
        return !(self.emailField.text == "" || self.passwordField.text == "")
    }
    
    func updateUIElements() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "tabbarVC") as! tabbarVC
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    func checkIfUserExists(_ user: User, completionHandler: @escaping (Bool) -> ()) {
        Database.database().reference().child("users").child(user.uid).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.value is NSNull {
                completionHandler(false)
            } else {
                let userDict:[String:AnyObject] = snapshot.value as! [String:AnyObject]
                if(userDict["createdAt"] != nil){
                    completionHandler(true)
                } else{
                    completionHandler(false)
                }
            }
        }
    }
    
    func walkthrough() {
        
        self.backgroundImageNames = ["screen1","screen2", "screen3"]
        
        self.introductionView = self.simpleIntroductionView()
        self.introductionView?.modalPresentationStyle = .custom
        self.introductionView?.modalTransitionStyle = .crossDissolve
        present(introductionView!, animated: true, completion: nil)
        
        self.introductionView?.didSelectedEnter = {
            
            self.dismiss(animated: true, completion: nil)
            self.introductionView = nil;
            
        }
        
    }
    
    func simpleIntroductionView() -> ZWIntroductionViewController {
        let vc = ZWIntroductionViewController(coverImageNames: self.backgroundImageNames)
        return vc!
    }
    
    //Launch only First Time
    func isAppAlreadyLaunchedOnce()->Bool{
        
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil{
            
            KVNProgress.show()
            print("App already launched")
            
            if (Auth.auth().currentUser) != nil {
                
                KVNProgress.show()
                let user = Auth.auth().currentUser
                self.checkIfUserExists(user!, completionHandler: { (exists) in
                    KVNProgress.show()
                    if(exists){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.updateUIElements()
                            KVNProgress.dismiss()
                        }
                    }else{
                        KVNProgress.show()
                        
                        let params: [String : Any] = ["redirect": false, "height": 400, "width": 400, "type": "large"]
                        let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture", parameters: params, httpMethod: "GET")
                        pictureRequest?.start(completionHandler: {
                            (connection, result, error) -> Void in
                            if error == nil {
                                print("\(result!)")
                                
                                let dictionary = result as? [String:Any]
                                let dataDic = dictionary?["data"] as? [String:Any]
                                let urlPic = dataDic?["url"] as? String
                                
                                userModel.imageURL = urlPic
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    
                                    KVNProgress.dismiss()
                                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = storyboard.instantiateViewController(withIdentifier: "enterdetailnav") as! UINavigationController
                                    vc.modalPresentationStyle = .custom
                                    vc.modalTransitionStyle = .crossDissolve
                                    self.present(vc, animated: true, completion: nil)
                                }
                                
                                
                            } else {
                                print("\(error)")
                            }
                        })
                        
                        userModel.fullName = user!.displayName! as String
                        userModel.email = user!.email! as String
                        userModel.uid = user!.uid as String
                        
                    }
                })
                
            }else {
                KVNProgress.dismiss()
            }
            return true
        }
        else {
            
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            
            do {
                KVNProgress.dismiss()
                try Auth.auth().signOut()
                walkthrough()
            }catch {
                //
            }
            
            return false
        }
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
}
