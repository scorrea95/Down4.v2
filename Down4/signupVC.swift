//
//  signupVC.swift
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

class signupVC: UIViewController {

    @IBOutlet weak var fullnameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fullnameField.attributedPlaceholder = NSAttributedString(string:"Full Name",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.white])
        emailField.attributedPlaceholder = NSAttributedString(string:"Email",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.white])
        passwordField.attributedPlaceholder = NSAttributedString(string:"Password",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        signupButton.layer.cornerRadius = 13
        signupButton.layer.masksToBounds = true
        signupButton.addTarget(self, action:#selector(self.signupPressed), for: .touchUpInside)
        
        fbButton.layer.cornerRadius = 13
        fbButton.layer.masksToBounds = true
        fbButton.addTarget(self, action:#selector(self.FBsignIN), for: .touchUpInside)
        
    }
    
    func signupPressed() {
        
        if validateEmail(emailField.text!)
        {
            self.register()
        }else{
            
        }
    }
    
    func validateEmail(_ email: String) -> Bool {
        if email.characters.count == 0 {
            let alert = UIAlertController(title: "Email", message: "Email field should not be empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        let regExPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let regEx = try! NSRegularExpression(pattern: regExPattern, options: .caseInsensitive)
        let regExMatches = regEx.numberOfMatches(in: email, options: [], range: NSRange(location: 0, length: email.characters.count))
        if regExMatches == 0 {
            let alert = UIAlertController(title: "Email", message: "Enter proper email", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else {
            return true
        }
    }
    
    func register(){
        
        KVNProgress.show()
        
        if requiredFieldsAreNotEmpty() {
            
            userModel.fullName = self.fullnameField.text!
            userModel.email = self.emailField.text!
            userModel.password = self.passwordField.text
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                KVNProgress.dismiss()
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "enterdetailnav") as! UINavigationController
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }else{
            KVNProgress.dismiss()
            let alert = UIAlertController(title: "Empty Field", message: "Please provide all information.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
//        KVNProgress.show(withStatus: "Creating new account...")
//        
//        Auth.auth().createUser(withEmail: "\(self.emailField.text!)", password: "\(self.passwordField.text!)" ) {
//            user, error in
//            
//            if error == nil {
//                
//                let newUser:[String:AnyObject] = [
//                    "fullname" : self.fullnameField.text! as AnyObject,
//                    "email"    : self.emailField.text! as AnyObject,
//                    "createdAt": Date.init().timeIntervalSince1970 as AnyObject,
//                    "uid": user?.uid as AnyObject
//                ]
//                Database.database().reference().child("users").child((user?.uid)!).updateChildValues(newUser) { (error, ref) in
//                    if error == nil{
//                        
//                        KVNProgress.dismiss()
//                        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                        let vc = storyboard.instantiateViewController(withIdentifier: "enterdetailnav")
//                        vc.modalPresentationStyle = .custom
//                        vc.modalTransitionStyle = .crossDissolve
//                        self.present(vc, animated: true, completion: nil)
//                        
//                    } else{
//                        // error creating user
//                        KVNProgress.dismiss()
//                        let alert = UIAlertController(title: "Bad News", message: (error?.localizedDescription)!, preferredStyle: UIAlertControllerStyle.alert)
//                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                }
//            }else{
//                // error creating user
//                KVNProgress.dismiss()
//                let alert = UIAlertController(title: "Bad News", message: (error?.localizedDescription)!, preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)            }
//        }
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
                                userModel.uid = user!.uid as String
                            }
                        })
                    }
                }
            }
        });
    }
    
    func requiredFieldsAreNotEmpty() -> Bool {
        return !(self.fullnameField.text == "" || self.passwordField.text == "")
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
    
    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    @IBAction func unwindToSignup(segue: UIStoryboardSegue) {}
    
}
