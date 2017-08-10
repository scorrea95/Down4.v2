//
//  EventfeedVC.swift
//  Down4
//
//  Created by amrun on 04/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import DateToolsSwift
import PullToRefreshSwift

class EventfeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var defaultImageViewHeightConstraint:CGFloat = 160.0
    
    var posts = [Posts]()
    var user = [userItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
        
        var options = PullToRefreshOption()
        options.indicatorColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
        
        self.tableView.addPullRefresh(options: options, refreshCompletion: { [weak self] in
            // some code
            
            self?.fetchPosts()
        })
        
        self.tableView.startPullRefresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchPosts), name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
    }
    
    func fetchPosts() {
        
        posts.removeAll()
        self.tableView.reloadData()
        Database.database().reference().child("eventfeed").observe(.childAdded, with: { (snapshot:DataSnapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            self.posts.append(Posts(dictionary: dictionary))
            DispatchQueue.main.async(execute: {
                
                self.posts.sort(by: {$0.timestamp! > $1.timestamp!})
                self.tableView.reloadData()
                self.tableView.stopPullRefreshEver()
                
//                print(dictionary["uid"] as! String)

               
//                for (_,value) in dictionary {
//                
//                    let uid = value["uid"] as? String
//                        
//                    print(uid)
//                    
//                    
//                }
                
//                for child in snapshot.children {
//                    
//                    let snap = child as! DataSnapshot //each child is a snapshot
//                    print(snap.value!)
////                    let dict = snap.value as! [String: AnyObject] // the value is a dict
//                    
////                    let uid = dict["uid"]
//                    
////                    print("\(uid)")
//                }
                
            })
            
//            let uid = dictionary["uid"] as! String
            
//            Database.database().reference().child("users/\(uid)").observe(.childAdded, with: { (snapshot:DataSnapshot) in
//                
//                guard let userdictionary = snapshot.value as? [String: AnyObject] else {
//                    return
//                }
//                
//                self.user.append(userItem(dictionary: userdictionary))
//                
//                print(userdictionary["displayName"] as! String)
//            })
            
        }){(error) in
            
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! eventFeedCell
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapMediaInPost(_:)))
        cell.postImage.addGestureRecognizer(imageTap)
        
        cell.name.text = posts[indexPath.row].name
        
//        print(user[indexPath.row].fullName)
        
        let timestamp = posts[indexPath.row].timestamp
        let dateTimeStamp = Date(timeIntervalSince1970: Double(timestamp!)!)
        cell.time.text = dateTimeStamp.shortTimeAgoSinceNow
        
        let pic = posts[indexPath.row].image
        let url = URL(string:pic!)
        cell.profilePic.layer.cornerRadius =  cell.profilePic.frame.width/2
        cell.profilePic.clipsToBounds = true
        cell.profilePic!.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "circle"))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedProfilepic(_:)))
        cell.profilePic.addGestureRecognizer(tap)
        cell.profilePic.isUserInteractionEnabled = true
        cell.profilePic.tag = indexPath.row
        
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
        
        return cell
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
    
    func tappedProfilepic(_ sender:UITapGestureRecognizer)
    {
        if let row = sender.view?.tag {
            // use row number
            print("row number is \(row)")
            print(self.posts[row].uid!)
             
//            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "SProfileVC") as! SProfileVC
//            vc.uid = self.posts[row].uid!
//            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
