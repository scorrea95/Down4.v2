//
//  FriendsVC.swift
//  Down4
//
//  Created by amrun on 04/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class FriendsVC: UIViewController {

    @IBOutlet weak var segment: BetterSegmentedControl!
    @IBOutlet weak var friendActivityView: UIView!
    @IBOutlet weak var friendListView: UIView!
    @IBOutlet weak var newRequestView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SegmentedControl: Created and designed in IB that announces its value on interaction
        segment.titles = ["Friends","Requests"]
        segment.titleFont = UIFont(name: "HelveticaNeue-Medium", size: 13.0)!
        segment.selectedTitleFont = UIFont(name: "HelveticaNeue-Medium", size: 13.0)!
        segment.layer.borderWidth = 1
        segment.layer.borderColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0).cgColor
        segment.alwaysAnnouncesValue = true
        segment.announcesValueImmediately = false
        segment.addTarget(self, action: #selector(self.SegmentedControlValueChanged(_:)), for: .valueChanged)
        
        self.friendActivityView.isHidden = false
        self.friendListView.isHidden = true
        self.newRequestView.isHidden = true

    }
    
    // MARK: - Action handlers
    func SegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
       
        if sender.index == 0 {
            print("Friends")
            UIView.animate(withDuration: 0.5, animations: {
                self.friendActivityView.isHidden = true
                self.friendListView.isHidden = false
                self.newRequestView.isHidden = true
            })
        }else if sender.index == 1 {
            print("Requests")
            UIView.animate(withDuration: 0.5, animations: {
                self.friendActivityView.isHidden = true
                self.friendListView.isHidden = true
                self.newRequestView.isHidden = false
            })
        }
    }


}
