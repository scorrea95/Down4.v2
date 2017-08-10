//
//  ProfileVC.swift
//  Down4
//
//  Created by amrun on 04/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import MXSegmentedPager

class ProfileVC: MXSegmentedPagerController {
    
    var headerView = profileHeaderVC()
//    var popRecognizer: InteractivePopRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedPager.backgroundColor = .white
        
        headerView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileHeaderVC") as! profileHeaderVC
        
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
        
        removeValues()
        
//         setInteractiveRecognizer()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showTitle), name: NSNotification.Name(rawValue: "showTitle"), object: nil)

    }
    
//    private func setInteractiveRecognizer() {
//        guard let controller = navigationController else { return }
//        popRecognizer = InteractivePopRecognizer(controller: controller)
//        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
//    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        // Hide the navigation bar on the this view controller
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        // Show the navigation bar on other view controllers
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//    }

    override func heightForSegmentedControl(in segmentedPager: MXSegmentedPager) -> CGFloat {
        return 44
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return ["Upcoming Events", "My Events"][index]
    }

    func removeValues() {
        userModel.uid = nil
        userModel.userImage = nil
        userModel.imageURL = nil
        userModel.fullName = nil
        userModel.birthdate = nil
        userModel.email = nil
        userModel.password = nil
        userModel.phone = nil
        userModel.gender = nil
        userModel.college = nil
        userModel.location = nil
        userModel.username = nil
        userModel.notiToken = nil
    }
    
    func showTitle() {
        self.title = "\(userModel.username!)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mx_page_0"{
//            let dest = segue.destination as! upcomingEventsVC
//            dest.test = "teetetetteetetettetet"
        }else if segue.identifier == "mx_page_1"{
//            let dest = segue.destination as! myEventsVC
//            dest.test = "pottoptotptotpotpto"
        }else{
            
        }
    }
}

//class InteractivePopRecognizer: NSObject, UIGestureRecognizerDelegate {
//    
//    var navigationController: UINavigationController
//    
//    init(controller: UINavigationController) {
//        self.navigationController = controller
//    }
//    
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return navigationController.viewControllers.count > 1
//    }
//    
//    // This is necessary because without it, subviews of your top controller can
//    // cancel out your gesture recognizer on the edge.
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}
