//
//  enterDetailsVC.swift
//  Down4
//
//  Created by amrun on 02/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress
import SDWebImage
import LocationPickerViewController

class enterDetailsVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, LocationPickerDelegate {

    @IBOutlet weak var birthdateField: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var college: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var AddPhoto: UIImageView!
    
    @IBOutlet weak var addphotoButton: UIButton!
    @IBOutlet weak var createAccount: UIButton!
    
    var datePicker : UIDatePicker!
    var userImageURL: String?
    
    var pickerView1 = UIPickerView()
    var pickOption1 = ["Other", "Male", "Female"]   //gender picker options
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        birthdateField.attributedPlaceholder = NSAttributedString(string:"Birthdate",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        gender.attributedPlaceholder = NSAttributedString(string:"Gender",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        college.attributedPlaceholder = NSAttributedString(string:"College",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        location.attributedPlaceholder = NSAttributedString(string:"Location",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        phoneNumber.attributedPlaceholder = NSAttributedString(string:"Phone Number",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        username.attributedPlaceholder = NSAttributedString(string:"Username",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.lightGray])

        phoneNumber.keyboardType = .numberPad
        
        AddPhoto.contentMode = .scaleAspectFill
        AddPhoto.clipsToBounds = true
        AddPhoto.layer.cornerRadius = AddPhoto.frame.size.width/2
        
        pickerView1.delegate = self
        
        birthdateField.delegate = self
        gender.delegate = self
        
        gender.inputView = pickerView1
        
        createAccount.layer.cornerRadius = 30
        createAccount.layer.masksToBounds = true
        createAccount.addTarget(self, action:#selector(self.createAccountPressed), for: .touchUpInside)
    
        populateData()
    }
    
    func populateData() {
        if(userModel.imageURL != nil){
            let url = URL(string:(userModel.imageURL ?? nil)!)
            self.AddPhoto.sd_setImage(with: url, placeholderImage: nil)
            self.addphotoButton.setImage(nil, for: .normal)
        }
    }
    
    
    func fbprofile() {
        
        userModel.phone = self.phoneNumber.text!
        userModel.gender = self.gender.text!
        userModel.birthdate = self.birthdateField.text
        userModel.location = self.location.text
        userModel.college = self.college.text
        userModel.username = self.username.text
        
        let key = Database.database().reference().childByAutoId().key
        let storageRef = Storage.storage().reference()
        let pictureStorageRef = storageRef.child("users/\(Auth.auth().currentUser!.uid)/photos/\(key).jpg")
        
        let Data = UIImageJPEGRepresentation(self.AddPhoto.image!, 0.5)
        
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        if(Data != nil){
            
         pictureStorageRef.putData(Data!,metadata: meta){metadata,error in
                
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let newUser:[String:Any] = [
                        "email"    : userModel.email! as String,
                        "createdAt": "\(Date.init().timeIntervalSince1970)" as String,
                        "uid": userModel.uid! as String,
                        "displayName": userModel.fullName! as String,
                        "image"    : downloadUrl!.absoluteString as String,
                        "Gender": userModel.gender! as String,
                        "DOB": userModel.birthdate! as String,
                        "Phone": userModel.phone! as String,
                        "location": userModel.location! as String,
                        "college": userModel.college! as String,
                        "username": userModel.username! as String,
                        "latitude": "" as AnyObject,
                        "longitude": "" as AnyObject,
                        "State": "" as String,
                        "City": "" as String,
                        "Clout": 0 as Int
                    ]
                    Database.database().reference().child("users").child((userModel.uid)!).updateChildValues(newUser) { (error, ref) in
                        if error == nil{
                            
                            KVNProgress.dismiss()
                            
                            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "tabbarVC") as! tabbarVC
                            vc.modalPresentationStyle = .custom
                            vc.modalTransitionStyle = .crossDissolve
                            self.present(vc, animated: true, completion: nil)
                            
//                            let locationPicker = LocationPicker()
//                            locationPicker.delegate = self
//                            locationPicker.currentLocationIconColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
//                            locationPicker.searchResultLocationIconColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
//                            locationPicker.pinColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
//                            locationPicker.title = "Select Location"
//                            self.navigationController?.pushViewController(locationPicker, animated: true)
//                            
//                            // Completion closures
//                            locationPicker.selectCompletion = { selectedLocationItem in
//                                print("Select completion closure: " + selectedLocationItem.name)
//                                
//                                //                                print(selectedLocationItem.addressDictionary)
//                                //                                print((selectedLocationItem.addressDictionary?["Country"])!)
//                                
//                                SVProgressHUD.show()
//                                
//                                if(selectedLocationItem.addressDictionary?["City"] != nil){
//                                    Fire.shared.updateUserWithKeyAndValue("City", value: (selectedLocationItem.addressDictionary?["City"])! as AnyObject, completionHandler: nil)
//                                }else{
//                                    Fire.shared.updateUserWithKeyAndValue("City", value: "" as AnyObject, completionHandler: nil)
//                                }
//                                
//                                if(selectedLocationItem.addressDictionary?["State"] != nil){
//                                    Fire.shared.updateUserWithKeyAndValue("State", value: (selectedLocationItem.addressDictionary?["State"])! as AnyObject, completionHandler: nil)
//                                }else{
//                                    Fire.shared.updateUserWithKeyAndValue("State", value: "" as AnyObject, completionHandler: nil)
//                                }
//                                
//                                Fire.shared.updateUserWithKeyAndValue("latitude", value: (selectedLocationItem.coordinate?.latitude) as AnyObject, completionHandler: nil)
//                                Fire.shared.updateUserWithKeyAndValue("longitude", value: (selectedLocationItem.coordinate?.longitude) as AnyObject, completionHandler: nil)
                            
//                            }
                
                        }else{
                            // error creating user
                            print(error!.localizedDescription)
                            KVNProgress.dismiss()
                            let alert = UIAlertController(title: "Alert!", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }else{
                    
                    print(error!.localizedDescription)
                    KVNProgress.dismiss()
                    let alert = UIAlertController(title: "Alert!", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        if(Data == nil){
            print("image data is nil")
        }
        
    }
    
    func createAccountPressed() {
        
        KVNProgress.show()
        
        if requiredFieldsAreNotEmpty() {
            
            if(userModel.uid != nil){
                
                fbprofile()
                
            }else{
                
                userModel.phone = self.phoneNumber.text!
                userModel.gender = self.gender.text!
                userModel.birthdate = self.birthdateField.text
                userModel.location = self.location.text
                userModel.college = self.college.text
                userModel.username = self.username.text
                
                Auth.auth().createUser(withEmail: userModel.email!, password: userModel.password!, completion: {
                    user, error in
                    
                    if error == nil {
                        
                        userModel.uid = user?.uid
                        
                        let key = Database.database().reference().child("Photos").childByAutoId().key
                        let storageRef = Storage.storage().reference()
                        let pictureStorageRef = storageRef.child("users/\(Auth.auth().currentUser!.uid)/photos/\(key)")
                        
                        let Data = UIImageJPEGRepresentation(self.AddPhoto.image!, 0.5)
                        
                        if(Data != nil){
                            
                            let uploadTask = pictureStorageRef.putData(Data!,metadata: nil)
                            {metadata,error in
                                
                                if(error == nil)
                                {
                                    let downloadUrl = metadata!.downloadURL()
                                    
                                    let newUser:[String:Any] = [
                                        "email"    : userModel.email! as String,
                                        "createdAt": "\(Date.init().timeIntervalSince1970)" as String,
                                        "uid": userModel.uid! as String,
                                        "displayName": userModel.fullName! as String,
                                        "image"    : downloadUrl!.absoluteString as String,
                                        "Gender": userModel.gender! as String,
                                        "DOB": userModel.birthdate! as String,
                                        "Phone": userModel.phone! as String,
                                        "location": userModel.location! as String,
                                        "college": userModel.college! as String,
                                        "username": userModel.username! as String,
                                        "latitude": "" as AnyObject,
                                        "longitude": "" as AnyObject,
                                        "State": "" as String,
                                        "City": "" as String,
                                        "Clout": 0 as Int
                                    ]
                                    Database.database().reference().child("users").child((user?.uid)!).updateChildValues(newUser) { (error, ref) in
                                        if error == nil{
                                            
                                            KVNProgress.dismiss()
                                            
                                            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                            let vc = storyboard.instantiateViewController(withIdentifier: "tabbarVC") as! tabbarVC
                                            vc.modalPresentationStyle = .custom
                                            vc.modalTransitionStyle = .crossDissolve
                                            self.present(vc, animated: true, completion: nil)
                                            
//                                            let locationPicker = LocationPicker()
//                                            locationPicker.delegate = self
//                                            locationPicker.currentLocationIconColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
//                                            locationPicker.searchResultLocationIconColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
//                                            locationPicker.pinColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
//                                            locationPicker.title = "Select Location"
//                                            self.navigationController?.pushViewController(locationPicker, animated: true)
//                                            
//                                            // Completion closures
//                                            locationPicker.selectCompletion = { selectedLocationItem in
//                                                print("Select completion closure: " + selectedLocationItem.name)
//                                                
//                                                //                                                print(selectedLocationItem.addressDictionary)
//                                                //                                                print((selectedLocationItem.addressDictionary?["Country"])!)
//                                                
//                                                SVProgressHUD.show()
//                                                
//                                                if(selectedLocationItem.addressDictionary?["City"] != nil){
//                                                    Fire.shared.updateUserWithKeyAndValue("City", value: (selectedLocationItem.addressDictionary?["City"])! as AnyObject, completionHandler: nil)
//                                                }else{
//                                                    Fire.shared.updateUserWithKeyAndValue("City", value: "" as AnyObject, completionHandler: nil)
//                                                }
//                                                
//                                                if(selectedLocationItem.addressDictionary?["State"] != nil){
//                                                    Fire.shared.updateUserWithKeyAndValue("State", value: (selectedLocationItem.addressDictionary?["State"])! as AnyObject, completionHandler: nil)
//                                                }else{
//                                                    Fire.shared.updateUserWithKeyAndValue("State", value: "" as AnyObject, completionHandler: nil)
//                                                }
//                                                
//                                                Fire.shared.updateUserWithKeyAndValue("latitude", value: (selectedLocationItem.coordinate?.latitude) as AnyObject, completionHandler: nil)
//                                                Fire.shared.updateUserWithKeyAndValue("longitude", value: (selectedLocationItem.coordinate?.longitude) as AnyObject, completionHandler: nil)
//
//                                            }
                                            
                                        }else{
                                            // error creating user
                                            print(error!.localizedDescription)
                                            KVNProgress.dismiss()
                                            let alert = UIAlertController(title: "Alert!", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                                            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                    }
                                    
                                }else{
                                    print(error!.localizedDescription)
                                    KVNProgress.dismiss()
                                    let alert = UIAlertController(title: "Alert!", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)                                }
                            }
                        }
                        if(Data == nil){
                            print("image data is nil")
                        }
                    }else{
                        print(error?.localizedDescription)
                        
                        print(error!.localizedDescription)
                        KVNProgress.dismiss()
                        let alert = UIAlertController(title: "Alert!", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                
            }
        }else{
            KVNProgress.dismiss()
            let alert = UIAlertController(title: "Empty Field", message: "Please provide all information.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func addPhotoPressed(_ sender: Any) {
        let alert = UIAlertController.init(title: "Upload Profile Image", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction.init(title: "Camera", style: .default) { (action) in
            self.openImagePicker(.camera)
        }
        let action2 = UIAlertAction.init(title: "Photos", style: .default) { (action) in
            self.openImagePicker(.photoLibrary)
        }
        let action3 = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in }
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
    
        self.present(alert, animated: true, completion: nil)
    }
    
    func openImagePicker(_ sourceType:UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        imagePicker.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white
        ]
        self.navigationController?.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        self.AddPhoto.image = image
        self.addphotoButton.setImage(nil, for: .normal)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickUpDate(self.birthdateField)
        
    }
    
    func requiredFieldsAreNotEmpty() -> Bool {
        return !(self.birthdateField.text == "" || self.gender.text == "" || self.college.text == "" || self.location.text == "" || self.phoneNumber.text == "" || self.username.text == "" || self.AddPhoto.image == nil)
    }
    
    //MARK:- Function of datePicker
    func pickUpDate(_ textField : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.date
        textField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    // MARK:- Button Done and Cancel
    func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        dateFormatter1.timeStyle = .none
        birthdateField.text = dateFormatter1.string(from: datePicker.date)
        birthdateField.resignFirstResponder()
    }
    
    func cancelClick() {
        birthdateField.resignFirstResponder()
    }
    
    // picker option
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(gender.isEditing){
            return pickOption1.count
        }else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(gender.isEditing){
            return pickOption1[row]
        }else{
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if(gender.isEditing){
            gender.text = pickOption1[row]
        }else{
            
        }
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToSignup", sender: self)
    }

}
