//
//  BoardVC.swift
//  Down4
//
//  Created by amrun on 04/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import BetterSegmentedControl
import KVNProgress

class BoardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segment: BetterSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var clout: UILabel!
    
    var users = [userItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        
        // SegmentedControl: Created and designed in IB that announces its value on interaction
        segment.titles = ["School","Overall"]
        segment.titleFont = UIFont(name: "HelveticaNeue-Medium", size: 13.0)!
        segment.selectedTitleFont = UIFont(name: "HelveticaNeue-Medium", size: 13.0)!
        segment.layer.borderWidth = 1
        segment.layer.borderColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0).cgColor
        segment.alwaysAnnouncesValue = true
        segment.announcesValueImmediately = false
        segment.addTarget(self, action: #selector(self.SegmentedControlValueChanged(_:)), for: .valueChanged)
        
        fetchUsers()
    }
    
    func fetchUsers() {
        KVNProgress.show()
        users.removeAll()
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                self.users.append(userItem(dictionary: dictionary))
                DispatchQueue.main.async(execute: {
                    self.users.sort(by: {$0.clout! > $1.clout!})
                    self.tableView.reloadData()
                    KVNProgress.dismiss()
                })
            }){(error) in
                
                print(error.localizedDescription)
            }
    }
    
    // MARK: - Action handlers
    func SegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        
        if sender.index == 0 {
            print("School")
            
            self.tableView.reloadData()
        }else {
            print("Overall")
            
            self.tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! userTableCell
        
        cell.userName.text = users[indexPath.row].fullName
        cell.username.text = "@\(users[indexPath.row].username!)"
        
        cell.clout.text = "\(users[indexPath.row].clout!)"
        
        cell.rank.text = "\(indexPath.row + 1)"
        
        let picture = users[indexPath.row].imageURL
        let url = URL(string:picture!)
        cell.profileImage!.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if users[indexPath.row].uid == Auth.auth().currentUser?.uid {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SProfileVC") as! SProfileVC
            vc.userDetails = users[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
