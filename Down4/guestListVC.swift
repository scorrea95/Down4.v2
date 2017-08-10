//
//  guestListVC.swift
//  Down4
//
//  Created by amrun on 07/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress

class guestListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var guests = [userItem]()
    var key: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchGuests()
    }
    
    func fetchGuests() {
        
        guests.removeAll()
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        Database.database().reference().child("events/\(self.key!)/guests").observe(.childAdded, with: { (snapshot) in
            
            let uid = snapshot.key
            
            Database.database().reference().child("users/\(uid)").observeSingleEvent(of: .value, with: {(snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                self.guests.append(userItem(dictionary: dictionary))
                DispatchQueue.main.async(execute: {
//                    self.guests.sort(by: {$0.createdAt! > $1.createdAt!})
                    self.tableView.reloadData()
                    
                    print(dictionary)
                    
                })
            }){(error) in
                
                print(error.localizedDescription)
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if guests.count > 0 {
            
//            collectionVIew.backgroundView = UIImageView(image: nil)
            return 1
            
        }else{
            
//            collectionVIew.backgroundView = UIImageView(image: #imageLiteral(resourceName: "noupcomingevents"))
//            collectionVIew.backgroundView?.contentMode = .scaleAspectFill
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.guests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! userTableCell
        
        cell.userName.text = guests[indexPath.row].fullName
        
        let picture = guests[indexPath.row].imageURL
        let url = URL(string:picture!)
        cell.profileImage!.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if guests[indexPath.row].uid == Auth.auth().currentUser?.uid {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SProfileVC") as! SProfileVC
            vc.userDetails = guests[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
