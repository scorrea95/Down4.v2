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

class EventsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var events = [eventModel]()
  //  var filteredEvents = [eventModel]()
    
    
    var searchController: UISearchController!
    var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    //    filteredEvents = events
  //     searchController.searchResultsUpdater = self
  //      searchController.dimsBackgroundDuringPresentation = true
  //      definesPresentationContext = true
    //       searchController.searchBar.scopeButtonTitles = ["Greek Life", "Campus Events", "Parties", "Sports/Live Events", "Other"]
    //      searchController.searchBar.delegate = self

        var options = PullToRefreshOption()
        options.indicatorColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
        
        self.collectionView.addPullRefresh(options: options, refreshCompletion: { [weak self] in
            // some code
            
            self?.fetchPosts()
            self?.events.removeAll()
            self?.collectionView.reloadData()
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


    //if we havnt typed anything to the search bar then do not use the search text to filter the results
   
     func applySearch(searchText: String, scope: String = "Greek Life") {
        if searchController.searchBar.text! == "" {
            events = events.filter { event in
                let eventCategory = (scope == "Greek Life") || (event.category == scope)
            return eventCategory
        }
     
     //if we have typed something into the search bar, then we also filter the results for the search bar
     
    } else {
                events = events.filter { event in
                let eventCategory = (scope == "Greek Life") || (event.category == scope)
                return eventCategory && event.eventTitle!.lowercased().contains(searchText.lowercased())
                
        }
    }
    
    self.collectionView.reloadData()
    
    
}

    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let selectedScope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        applySearch(searchText: searchController.searchBar.text!, scope: selectedScope)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
       applySearch(searchText: searchController.searchBar.text!,scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    

    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchText = searchBar.text!
        self.navigationItem.title = searchText.uppercased()
        self.searchEvents(searchText: searchText)
        self.searchEvents1(searchText: searchText)
        self.searchEvents2(searchText: searchText)
        self.searchEvents3(searchText: searchText)
        self.collectionView!.reloadData()
        self.dismiss(animated: true, completion: nil)
}


    @IBAction func searchAction(_ sender: Any) {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.text = searchText
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.barTintColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.scopeButtonTitles = ["Greek Life", "Campus Events", "Parties", "Sports/Live Events",]
        searchController.searchResultsUpdater = self
        self.present(searchController, animated: true, completion: nil)
        
        
        
        
    }


    func searchEvents(searchText: String){
        events.removeAll()
        self.collectionView.reloadData()
         let ref = Database.database().reference().child("events")
       let query = ref.queryOrdered(byChild: "category").queryEqual(toValue: "Greek Life")
        query.observe(.value, with: { (snapshot) in
            for childSnapshot in snapshot.children {
                print(childSnapshot)
            }
        })
     
        
    }
    func searchEvents1(searchText: String){
        events.removeAll()
        self.collectionView.reloadData()
        let ref = Database.database().reference().child("events")
        let query = ref.queryOrdered(byChild: "category").queryEqual(toValue: "Campus Events")
        query.observe(.value, with: { (snapshot) in
            for childSnapshot in snapshot.children {
                print(childSnapshot)
            }
        })
        
        
    }
    func searchEvents2(searchText: String){
        events.removeAll()
        self.collectionView.reloadData()
        let ref = Database.database().reference().child("events")
        let query = ref.queryOrdered(byChild: "category").queryEqual(toValue: "Parties")
        query.observe(.value, with: { (snapshot) in
            for childSnapshot in snapshot.children {
                print(childSnapshot)
            }
        })
        
        
    }
    func searchEvents3(searchText: String){
        events.removeAll()
        self.collectionView.reloadData()
        let ref = Database.database().reference().child("events")
        let query = ref.queryOrdered(byChild: "category").queryEqual(toValue: "Sports/Live Events")
        query.observe(.value, with: { (snapshot) in
            for childSnapshot in snapshot.children {
                print(childSnapshot)
            }
        })
        
        
    }





}

















