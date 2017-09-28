//
//  FirstViewController.swift
//  Example-KatsanaSDK
//
//  Created by Wan Lutfi on 28/09/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import UIKit
import KatsanaSDK

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func login() {
        KatsanaAPI.configure(clientId: <#T##String#>, clientSecret: <#T##String#>, grantType: <#T##String#>)
    }

}

