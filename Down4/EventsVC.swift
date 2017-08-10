//
//  EventsVC.swift
//  Down4
//
//  Created by amrun on 03/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import KVNProgress
import PullToRefreshSwift
import UserNotifications

class EventsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var events = [eventModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var options = PullToRefreshOption()
        options.indicatorColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
        
        self.collectionView.addPullRefresh(options: options, refreshCompletion: { [weak self] in
            // some code
            
            self?.fetchPosts()
        })
        
        self.collectionView.startPullRefresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchPosts), name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
        
        self.notificationPermission()
    }
    
    func fetchPosts() {
        
        events.removeAll()
        self.collectionView.reloadData()
        Database.database().reference().child("events").observe(.childAdded, with: { (snapshot:DataSnapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            self.events.append(eventModel(dictionary: dictionary))
            DispatchQueue.main.async(execute: {
                self.events.sort(by: {$0.createdAt! > $1.createdAt!})
                self.collectionView.reloadData()
                self.collectionView.stopPullRefreshEver()
            })
        }){(error) in
            print(error.localizedDescription)
        }
    }

    @IBAction func filterPressed(_ sender: Any) {
 //       let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
  //      let vc = storyboard.instantiateViewController(withIdentifier: "filterEventVC") as! filterEventVC
   //    self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func createEventPressed(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "createEventNav")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func guestCountPressed(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "guestListVC") as! guestListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! EventCollectionCell
        
        cell.EventTitle.text = events[indexPath.row].eventTitle

        cell.EventPlace.text = events[indexPath.row].placeName
        
        cell.guestCount.text = "\(events[indexPath.row].guestsCount!)"
        
        if(events[indexPath.row].eventCost! == "Free"){
            cell.EventCost.text = "Free"
        }else{
            cell.EventCost.text = "$\(events[indexPath.row].eventCost!)"
        }
        
        let date = events[indexPath.row].eventDate
        let time = events[indexPath.row].startTime
        cell.EventDateTime.text = "\(date!) @ \(time!)"
        
        let picture = events[indexPath.row].eventImage
        let url = URL(string:picture!)
        cell.eventImage!.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        
        cell.guestList.layer.setValue(indexPath.row, forKey: "index")
        cell.guestList.addTarget(self, action: #selector(self.guestListPressed(sender:)), for: .touchUpInside)

        return cell
    }
    
    func guestListPressed(sender:UIButton) {
        
        let row = (sender.layer.value(forKey: "index")) as! Int
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "guestListVC") as! guestListVC
        vc.key = events[row].key
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventDetailVC") as! EventDetailVC
        vc.events = events[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //register for notification
    func notificationPermission() {
        if #available(iOS 10.0, *) {
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    @IBAction func unwindToEvent(segue: UIStoryboardSegue) {}
}
