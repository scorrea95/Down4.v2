//
//  PostStoryVC.swift
//  HERO
//
//  Created by amrun on 08/03/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import KVNProgress

class PostStoryVC: UIViewController,UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var loggedInUserData:NSDictionary?
    
    @IBOutlet weak var newTweetTextView: UITextView!
    @IBOutlet weak var newTweetToolbar: UIToolbar!
    
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    var toolbarBottomConstraintInitialValue:CGFloat?
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newTweetToolbar.isHidden = false
        
        newTweetTextView.textContainerInset = UIEdgeInsetsMake(30, 20, 20, 20)
        newTweetTextView.text = "What's happening?"
        newTweetTextView.textColor = UIColor.lightGray
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: {(Snapshot) in
            
            //store the logged in users details into the variable
            self.loggedInUserData = Snapshot.value as? NSDictionary
            
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        enableKeyboardHideOnTap()
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        self.toolbarBottomConstraintInitialValue = toolbarBottomConstraint.constant
        newTweetTextView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
    }
    
    fileprivate func enableKeyboardHideOnTap(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    func keyboardWillShow(_ notification: Notification)
    {
        let info = (notification as NSNotification).userInfo!
        
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration, animations: {
            
            self.toolbarBottomConstraint.constant = keyboardFrame.size.height
            
            self.newTweetToolbar.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration, animations: {
            
            self.toolbarBottomConstraint.constant = self.toolbarBottomConstraintInitialValue!
            
            self.newTweetToolbar.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(newTweetTextView.textColor == UIColor.lightGray)
        {
            newTweetTextView.text = nil
            newTweetTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if newTweetTextView.text.isEmpty {
            newTweetTextView.text = "What's happening?"
            newTweetTextView.textColor = UIColor.lightGray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func didTapPost(_ sender: AnyObject) {
        
        KVNProgress.show()
        self.newTweetTextView.resignFirstResponder()
        
        if(newTweetTextView.text == "What's happening?"){
           KVNProgress.dismiss()
        }
        
        var imagesArray = [AnyObject]()
        
        //extract the images from the attributed text
        self.newTweetTextView.attributedText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, self.newTweetTextView.text.characters.count), options: []) { (value, range, true) in
            
            if(value is NSTextAttachment)
            {
                let attachment = value as! NSTextAttachment
                var image : UIImage? = nil
                
                if(attachment.image !== nil)
                {
                    image = attachment.image!
                    imagesArray.append(image!)
                }
                else
                {
                    print("No image found")
                }
            }
        }
        
        let tweetLength = newTweetTextView.text.characters.count
        let numImages = imagesArray.count
        
        //create a unique auto generated key from firebase database
        let key = Database.database().reference().childByAutoId().key
        
        let storageRef = Storage.storage().reference()
        let pictureStorageRef = storageRef.child("users/\(Auth.auth().currentUser!.uid)/media/\(key)")
        
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        //user has entered text and an image
        if(tweetLength>0 && numImages>0)
        {
            let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)
            
            pictureStorageRef.putData(lowResImageData!,metadata: meta){metadata,error in
                
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let childUpdates = [
                        "name":self.loggedInUserData?["displayName"] as! String,
                        "image":self.loggedInUserData?["image"] as! String!,
                        "text":self.newTweetTextView.text,
                        "timestamp":"\(Date().timeIntervalSince1970)",
                        "picture":downloadUrl!.absoluteString,
                        "key":key,
                        "uid":Auth.auth().currentUser!.uid] as [String : Any]
                    
                    Database.database().reference().child("/eventfeed/\(key)").updateChildValues(childUpdates) { (error, ref) in
                        if error == nil{
                            
                            KVNProgress.dismiss()
                            Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/eventfeed/\(key)").setValue(true)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
                            self.newTweetTextView.resignFirstResponder()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                
            }
        }
            //user has entered only text
        else if(tweetLength>0 && newTweetTextView.text != "What's happening?")
        {
            let childUpdates = [
                "name":self.loggedInUserData?["displayName"] as! String,
                "image":self.loggedInUserData?["image"] as! String!,
                "timestamp":"\(Date().timeIntervalSince1970)",
                "text":self.newTweetTextView.text,
                "key":key,
                "uid":Auth.auth().currentUser!.uid] as [String : Any]
            
            Database.database().reference().child("/eventfeed/\(key)").updateChildValues(childUpdates) { (error, ref) in
                if error == nil{
                    
                    KVNProgress.dismiss()
                    Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/eventfeed/\(key)").setValue(true)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
                    self.newTweetTextView.resignFirstResponder()
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
        }
            //user has entered only an image
        else if(numImages>0)
        {
            let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)
            
            pictureStorageRef.putData(lowResImageData!,metadata: nil)
            {metadata,error in
                
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let childUpdates = [
                        "name":self.loggedInUserData?["displayName"] as! String,
                        "image":self.loggedInUserData?["image"] as! String!,
                        "timestamp":"\(Date().timeIntervalSince1970)",
                        "picture":downloadUrl!.absoluteString,
                        "key":key,
                        "uid":Auth.auth().currentUser!.uid] as [String : Any]
                    
                    Database.database().reference().child("/social/\(key)").updateChildValues(childUpdates) { (error, ref) in
                        if error == nil{
                            
                            KVNProgress.dismiss()
                            Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/eventfeed/\(key)").setValue(true)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
                            self.newTweetTextView.resignFirstResponder()
                            self.dismiss(animated: true, completion: nil)
//                            self.performSegue(withIdentifier: "unwindToMenu", sender: self)
                            
                        }
                    }
                }
                else
                {
                    print(error!.localizedDescription)
                }
                
            }
            
            // dismiss(animated: true, completion: nil)
            
        }else if(tweetLength == 0){
        KVNProgress.dismiss()
        }
        
        
    }
    
    @IBAction func selectImageFromPhotos(_ sender: AnyObject) {
        
        //open the photo gallery
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    //after user has picked an image from photo gallery, this function will be called
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        var attributedString = NSMutableAttributedString()
        
        if(self.newTweetTextView.text.characters.count>0 && self.newTweetTextView.text != "What's happening?")
        {
            attributedString = NSMutableAttributedString(attributedString:self.newTweetTextView.attributedText)
        }
        else
        {
            attributedString = NSMutableAttributedString(string:"")
        }
        
        let textAttachment = NSTextAttachment()
        
        textAttachment.image = image
        
        let oldWidth:CGFloat = textAttachment.image!.size.width
        
        let scaleFactor:CGFloat = oldWidth/(newTweetTextView.frame.size.width-50)
        
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        
        attributedString.append(attrStringWithImage)
        
        newTweetTextView.attributedText = attributedString
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        newTweetTextView.resignFirstResponder()
       dismiss(animated: true, completion: nil)
    }
}
