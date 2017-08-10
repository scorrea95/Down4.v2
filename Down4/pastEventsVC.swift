//
//  pastEventsVC.swift
//  Down4
//
//  Created by amrun on 04/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import DateToolsSwift
import KVNProgress

class pastEventsVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var defaultImageViewHeightConstraint:CGFloat = 160.0
    
    var posts = [Posts]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
        
        self.fetchPosts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchPosts), name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
    }
    
    func fetchPosts() {
        
        posts.removeAll()
        self.tableView.reloadData()
        
        Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/eventfeed").observe(.childAdded, with: { (snapshot) in
            
            let key = snapshot.key
            
            Database.database().reference().child("eventfeed/\(key)").observeSingleEvent(of: .value, with: {(snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                self.posts.append(Posts(dictionary: dictionary))
                DispatchQueue.main.async(execute: {
                    
                    self.posts.sort(by: {$0.timestamp! > $1.timestamp!})
                    self.tableView.reloadData()

                })
            }){(error) in
                
                print(error.localizedDescription)
            }
       })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! eventFeedCell
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapMediaInPost(_:)))
        cell.postImage.addGestureRecognizer(imageTap)
        
        cell.name.text = posts[indexPath.row].name
        
        let timestamp = posts[indexPath.row].timestamp
        let dateTimeStamp = Date(timeIntervalSince1970: Double(timestamp!)!)
        cell.time.text = dateTimeStamp.shortTimeAgoSinceNow
        
        let pic = posts[indexPath.row].image
        let url = URL(string:pic!)
        cell.profilePic.layer.cornerRadius =  cell.profilePic.frame.width/2
        cell.profilePic.clipsToBounds = true
        cell.profilePic!.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "circle"))
        
        if(posts[indexPath.row].picture != nil && posts[indexPath.row].text != nil){
            
            cell.postImage.isHidden = false
            cell.imageViewHeightConstraint.constant = defaultImageViewHeightConstraint
            
            let picture = posts[indexPath.row].picture
            
            let url = URL(string:picture!)
            cell.postImage.layer.cornerRadius = 10
            cell.postImage.clipsToBounds = true
            cell.postImage!.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "Electro"))
            
            let post = posts[indexPath.row].text
            
            cell.post.text = post
            cell.post.numberOfLines = 0
            cell.post.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.post.sizeToFit()
        }
        else if(posts[indexPath.row].picture != nil && posts[indexPath.row].text == nil){
            
            cell.post.text = ""
            cell.postImage.isHidden = false
            cell.imageViewHeightConstraint.constant = defaultImageViewHeightConstraint
            
            let picture = posts[indexPath.row].picture
            
            let url = URL(string:picture!)
            cell.postImage.layer.cornerRadius = 10
            cell.postImage.clipsToBounds = true
            cell.postImage!.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "Electro"))
            
        }else if(posts[indexPath.row].text != nil && posts[indexPath.row].picture == nil){
            
            cell.postImage.isHidden = true
            cell.imageViewHeightConstraint.constant = 0
            
            let post = posts[indexPath.row].text
            
            cell.post.text = post
            cell.post.numberOfLines = 0
            cell.post.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.post.sizeToFit()
        }else{
            //...
        }
        
        cell.option.layer.setValue(indexPath.row, forKey: "index")
        cell.option.addTarget(self, action: #selector(self.optionPressed(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func optionPressed(sender:UIButton) {
        
        let row = (sender.layer.value(forKey: "index")) as! Int
        
        let alert = UIAlertController.init(title: "Please Select an option", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
            
            let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                
                KVNProgress.show()
                
                Database.database().reference().child("eventfeed/\(self.posts[row].key!)").removeValue(completionBlock: { (error, refer) in
                    if error != nil {
                        print(error!)
                    }else {
                        
                        print(refer)
                        Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/eventfeed/\(self.posts[row].key!)").removeValue()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
                        KVNProgress.dismiss()
                        
                    }
                })
                
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        let action2 = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in }
        alert.addAction(action1)
        alert.addAction(action2)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didTapMediaInPost(_ sender:UITapGestureRecognizer)
    {
        let imageView = sender.view as! UIImageView
        let imageInfo   = GSImageInfo(image: imageView.image!, imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: sender.view!)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        present(imageViewer, animated: true, completion: nil)
    }

}
