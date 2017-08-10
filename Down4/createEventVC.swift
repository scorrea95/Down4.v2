//
//  createEventVC.swift
//  Down4
//
//  Created by amrun on 04/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress
import BetterSegmentedControl

class createEventVC: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate {

    @IBOutlet weak var segment: BetterSegmentedControl!
    
    @IBOutlet weak var titletextView: UITextView!
    @IBOutlet weak var eventDetail: UITextView!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var cityandstate: UITextField!
    @IBOutlet weak var eventCost: UITextField!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var uploadimage: UIButton!
    @IBOutlet weak var selectCollege: UITextField!
    @IBOutlet weak var selectCategory: UITextField!
    
    var datePicker : UIDatePicker!
    var startTimePicker : UIDatePicker!
    var endTimePicker : UIDatePicker!
    
    var isPublic: Bool?
    
    var collegePicker = UIPickerView()
    var collegeNames = ["All Colleges", "Columbia University", "Cornell University", "Ithaca College", "Fordham University", "New York University", "Rutgers University", "Seton Hall University", "St. John's University", "Syracuse University"]
    
    var categoryPicker1 = UIPickerView()
    var categories1 = ["Greek Life", "Campus Events", "Parties", "Sports/Live Events", "Other"]
    
    var categoryPicker2 = UIPickerView()
    var categories2 = ["College Night Life", "Day-Time Events", "Career and Community Service Events"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        date.delegate = self
        date.inputView = self.datePicker
        
        startTime.delegate = self
        startTime.inputView = self.startTimePicker
        
        endTime.delegate = self
        endTime.inputView = self.endTimePicker
        
        collegePicker.delegate = self
        selectCollege.delegate = self
        selectCollege.inputView = self.collegePicker
        
        categoryPicker1.delegate = self
        categoryPicker2.delegate = self
        selectCategory.delegate = self
        selectCategory.inputView = self.categoryPicker1
        selectCategory.inputView = self.categoryPicker2

        
//        uploadimage.layer.cornerRadius = 30
//        uploadimage.layer.masksToBounds = true
        uploadimage.addTarget(self, action:#selector(self.uploadImagePressed), for: .touchUpInside)

        // SegmentedControl: Created and designed in IB that announces its value on interaction
        segment.titles = ["Public","Private"]
        segment.titleFont = UIFont(name: "HelveticaNeue-Medium", size: 13.0)!
        segment.selectedTitleFont = UIFont(name: "HelveticaNeue-Medium", size: 13.0)!
        segment.layer.borderWidth = 1
        segment.layer.borderColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0).cgColor
        segment.alwaysAnnouncesValue = true
        segment.announcesValueImmediately = false
        segment.addTarget(self, action: #selector(self.SegmentedControlValueChanged(_:)), for: .valueChanged)
        
        isPublic = true
    }
    
    // MARK: - Action handlers
    func SegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            print("Public")
            isPublic = true
            self.tableView.reloadData()
        }
        else {
            print("Private")
            isPublic = false
            self.tableView.reloadData()
        }
    }
    
    func uploadImagePressed() {
        let alert = UIAlertController.init(title: "Upload Event Poster", message: nil, preferredStyle: .actionSheet)
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
        self.eventImage.image = image
        self.uploadimage.setImage(nil, for: .normal)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createEventPressed(_ sender: Any) {
        
        if requiredFieldsAreNotEmpty() {
            
            KVNProgress.show()
            
            let key = Database.database().reference().childByAutoId().key
            let storageRef = Storage.storage().reference()
            let pictureStorageRef = storageRef.child("events/photos/\(Auth.auth().currentUser!.uid)/\(key)")
            
            let Data = UIImageJPEGRepresentation(self.eventImage.image!, 0.5)
            
            let meta = StorageMetadata()
            meta.contentType = "image/jpeg"
            
            if(Data != nil){
                
                pictureStorageRef.putData(Data!,metadata: meta){metadata,error in
                    
                    if(error == nil)
                    {
                        let downloadUrl = metadata!.downloadURL()
                        var cost: String?
                        if(self.eventCost.text == ""){
                            cost = "Free"
                        }else{
                            cost = self.eventCost.text
                        }
                        
                        let newEvent:[String:Any] = [
                            "eventTitle": self.titletextView.text! as String,
                            "createdAt": "\(Date.init().timeIntervalSince1970)" as String,
                            "uid": Auth.auth().currentUser!.uid as String,
                            "startTime": self.startTime.text! as String,
                            "eventImage": downloadUrl!.absoluteString as String,
                            "endTime": self.endTime.text! as String,
                            "eventDate": self.date.text! as String,
                            "placeName": self.placeName.text! as String,
                            "address": self.address.text! as String,
                            "cityandstate": self.cityandstate.text! as String,
                            "eventCost": cost! as String,
                            "eventDetail": self.eventDetail.text! as String,
                            "college": self.selectCollege.text! as String,
                            "category": self.selectCategory.text! as String,
                            "key": key as String,
                            "isPublic": self.isPublic as AnyObject,
                            "guestsCount": 0
                        ]
                        Database.database().reference().child("events/\(key)").updateChildValues(newEvent) { (error, ref) in
                            if error == nil{
                                
                                KVNProgress.dismiss()
                                self.dismiss(animated: true, completion: nil)
                                Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/eventPost/\(key)").setValue(true)
                                
                                DispatchQueue.main.async(execute: {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
                                })
                            
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
            }else{
                print("image data is nil")
                KVNProgress.dismiss()
            }
        }else{
            KVNProgress.dismiss()
            let alert = UIAlertController(title: "Empty Field", message: "Please provide all information.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //UITableView Delegates and DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return 3
        }else if section == 2{
            return 3
        }else if section == 3{
            if isPublic == true {
                return 4
            }else{
                return 2
            }
        }else{
            return 0
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickUpDate(self.date)
        self.pickUpDate(self.startTime)
        self.pickUpDate(self.endTime)
        
    }
    
    func requiredFieldsAreNotEmpty() -> Bool {
        
        if isPublic == true {
            return !(self.titletextView.text == "" || self.startTime.text == "" || self.date.text == "" || self.address.text == "" || self.cityandstate.text == "" || self.eventDetail.text == "" || self.eventImage.image == nil || self.selectCollege.text == "" || self.selectCategory.text == "")
        }else{
            return !(self.titletextView.text == "" || self.startTime.text == "" || self.date.text == "" || self.address.text == "" || self.cityandstate.text == "" || self.eventDetail.text == "" || self.eventImage.image == nil)
        }
        
    }
    
    //MARK:- Function of datePicker
    func pickUpDate(_ textField : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.date
        date.inputView = self.datePicker
        
        self.startTimePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.startTimePicker.backgroundColor = UIColor.white
        self.startTimePicker.datePickerMode = .time
        startTime.inputView = self.startTimePicker
        
        self.endTimePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.endTimePicker.backgroundColor = UIColor.white
        self.endTimePicker.datePickerMode = .time
        endTime.inputView = self.endTimePicker
        
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
        if date.isEditing{
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateStyle = .medium
            dateFormatter1.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
            dateFormatter1.timeStyle = .none
            date.text = dateFormatter1.string(from: datePicker.date)
            date.resignFirstResponder()
        }else if startTime.isEditing{
            let startTimeformatter = DateFormatter()
            startTimeformatter.timeStyle = .short
            startTime.text = startTimeformatter.string(from: startTimePicker.date)
            startTime.resignFirstResponder()
        }else{
            let endTimeformatter = DateFormatter()
            endTimeformatter.timeStyle = .short
            endTime.text = endTimeformatter.string(from: endTimePicker.date)
            endTime.resignFirstResponder()
        }
    }
    
    func cancelClick() {
        if date.isEditing{
            date.resignFirstResponder()
        } else if startTime.isEditing{
            startTime.resignFirstResponder()
        }else{
            endTime.resignFirstResponder()
        }
    }
    
    // picker option
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(selectCollege.isEditing){
            return collegeNames.count
        }else if(selectCategory.isEditing){
            if(selectCollege.text == "All Colleges"){
                return categories2.count
            }else{
                return categories1.count
            }
        }else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(selectCollege.isEditing){
            return collegeNames[row]
        }else if(selectCategory.isEditing){
            if(selectCollege.text == "All Colleges"){
                return categories2[row]
            }else{
                return categories1[row]
            }
        }else{
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if(selectCollege.isEditing){
            selectCollege.text = collegeNames[row]
            selectCategory.text = ""
        }else if(selectCategory.isEditing){
            if(selectCollege.text == "All Colleges"){
                selectCategory.text = categories2[row]
            }else{
                selectCategory.text = categories1[row]
            }
        }else{
            
        }
        
    }

}
