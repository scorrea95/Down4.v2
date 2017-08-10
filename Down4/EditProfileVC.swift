//
//  EditProfileVC.swift
//  Down4
//
//  Created by amrun on 08/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import LocationPickerViewController
import KVNProgress

class EditProfileVC: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, LocationPickerDelegate {

    @IBOutlet weak var FullName: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var college: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var DOB: UITextField!
    @IBOutlet weak var PhoneNumber: UITextField!
    @IBOutlet weak var City: UITextField!
    @IBOutlet weak var State: UITextField!
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var profileImageButton:UIButton!
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var userDetails: userItem?
    
    var datePicker : UIDatePicker!
    
    var pickerView1 = UIPickerView()
    var pickOption1 = ["Other", "Male", "Female"]   //gender picker options
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DOB.delegate = self
        gender.delegate = self
        
        pickerView1.delegate = self
        gender.inputView = pickerView1
        
        profileImageButton.addTarget(self, action: #selector(profilePictureButtonHandler), for: .touchUpInside)
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2

        fetchUserData()
    }

    func fetchUserData() {
        
        Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            self.userDetails = userItem(dictionary: dictionary)
            self.populateData()
            
        }){(error) in
            
            print(error.localizedDescription)
        }
    }
    
    func populateData() {
        
        FullName.text = userDetails?.fullName
        Email.text = userDetails?.email
        username.text = userDetails?.username
        college.text = userDetails?.college
        gender.text = userDetails?.gender
        DOB.text = userDetails?.birthdate
        PhoneNumber.text = userDetails?.phone
        State.text = userDetails?.State
        City.text = userDetails?.City
        currentLocation.text = "\(userDetails?.City ?? ""), \(userDetails?.State ?? "")"
        
        let picture = userDetails?.imageURL!
        let url = URL(string:picture!)
        self.profileImageView!.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "userplaceholder"))
    }

    @IBAction func Save(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Save Changes?", message: "Are you sure you want to save changes?", preferredStyle: UIAlertControllerStyle.alert)
        
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
                self.saveChanges()
         
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func saveChanges() {
        KVNProgress.show()
        
        let changes:[String:Any] = [
            "displayName": self.FullName.text! as String,
            "college": self.college.text! as String,
            "Gender": self.gender.text! as String,
            "DOB": self.DOB.text! as String,
            "Phone": self.PhoneNumber.text! as String,
            "latitude": userModel.latitude ?? "" as String,
            "longitude": userModel.longitude ?? "" as String,
            "State": self.State.text! as String,
            "City": self.City.text! as String
        ]
        Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)").updateChildValues(changes) { (error, ref) in
            if error == nil{
                KVNProgress.dismiss()
            }
        }
    }
    
    func profilePictureButtonHandler(_ sender:UIButton){
        let alert = UIAlertController.init(title: "Change Profile Image", message: nil, preferredStyle: .actionSheet)
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
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func openImagePicker(_ sourceType:UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        self.navigationController?.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        self.profileImageView.image = image
        self.navigationController?.dismiss(animated: true, completion: nil)
        
        self.spinner.startAnimating()
        self.profileImageView.alpha = 0.5
        
        let key = Database.database().reference().childByAutoId().key
        let storageRef = Storage.storage().reference()
        let pictureStorageRef = storageRef.child("users/\(Auth.auth().currentUser!.uid)/photos/\(key).jpeg")
        
        let data = UIImageJPEGRepresentation(image, 0.5)
    
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"

        if(data != nil){
            pictureStorageRef.putData(data!,metadata: meta){metadata,error in
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let newImage:[String:Any] = ["image": downloadUrl!.absoluteString as String]
                    Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)").updateChildValues(newImage) { (error, ref) in
                        if error == nil{
                            
                            self.spinner.stopAnimating()
                            self.profileImageView.alpha = 1
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchuser"), object: nil)
                            
                        }else{
                            // error adding image
                            print(error!.localizedDescription)
                            self.spinner.stopAnimating()
                            KVNProgress.dismiss()
                            let alert = UIAlertController(title: "Alert!", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        if(data == nil){
            print("image picker data is nil")
        }
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
            
            return 5
        }else if section == 2 {
            
            return 3
        }else {
            
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if indexPath.row == 0{
                
                let locationPicker = LocationPicker()
                locationPicker.delegate = self
                locationPicker.currentLocationIconColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
                locationPicker.searchResultLocationIconColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
                locationPicker.pinColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
                navigationController!.pushViewController(locationPicker, animated: true)
            }
        }
    }
    
    func locationDidPick(locationItem: LocationItem) {
        
        if(locationItem.addressDictionary?["City"] != nil && locationItem.addressDictionary?["State"] != nil){
            self.currentLocation.text = "\((locationItem.addressDictionary?["City"])!), \((locationItem.addressDictionary?["State"])!)"
            self.City.text = "\((locationItem.addressDictionary?["City"])!)"
            self.State.text = "\((locationItem.addressDictionary?["State"])!)"
            
            userModel.latitude = "\(locationItem.coordinate!.latitude)"
            userModel.longitude = "\(locationItem.coordinate!.longitude)"
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickUpDate(self.DOB)
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
        DOB.text = dateFormatter1.string(from: datePicker.date)
        DOB.resignFirstResponder()
    }
    
    func cancelClick() {
        DOB.resignFirstResponder()
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


}
