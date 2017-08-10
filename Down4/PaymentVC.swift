//
//  PaymentVC.swift
//  Down4
//
//  Created by amrun on 13/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit

class PaymentVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
