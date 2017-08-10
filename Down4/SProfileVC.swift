//
//  SProfileVC.swift
//  Down4
//
//  Created by amrun on 13/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import MXSegmentedPager

class SProfileVC: MXSegmentedPagerController {

     var headerView = SProfileHeaderVC()
    
    var userDetails: userItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedPager.backgroundColor = .white
        
        headerView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SProfileHeaderVC") as! SProfileHeaderVC
        headerView.userDetails = userDetails
        
        // Parallax Header
        segmentedPager.parallaxHeader.view = headerView.view
        self.addChildViewController(headerView)
        headerView.didMove(toParentViewController: self)
        segmentedPager.parallaxHeader.mode = .fill
        segmentedPager.parallaxHeader.height = 250
        segmentedPager.parallaxHeader.minimumHeight = 0
        segmentedPager.bounces = false
        
        // Segmented Control customization
        segmentedPager.segmentedControl.type = .text
        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.backgroundColor = .white
        segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black]
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)]
        segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        segmentedPager.segmentedControl.selectionIndicatorColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showTitle), name: NSNotification.Name(rawValue: "showTitle"), object: nil)
    }
    
    override func heightForSegmentedControl(in segmentedPager: MXSegmentedPager) -> CGFloat {
        return 44
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return ["Attending Events", "My Events"][index]
    }
    
    func showTitle() {
        self.title = "\(userModel.username!)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mx_page_0"{
            let dest = segue.destination as! SUpcomingEventsVC
            dest.userDetails = userDetails
        }else if segue.identifier == "mx_page_1"{
            let dest = segue.destination as! SMyEventsVC
            dest.userDetails = userDetails
        }else{
            
        }
    }


}
