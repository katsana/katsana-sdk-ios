//
//  ViewController.swift
//  KatsanaTest
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit
import KatsanaSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        test()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func test() {
        KatsanaAPI.sharedInstance.login(email: "", password: "") { (KMUser) in
            print("sdf")
        }
    }


    @IBAction func clicked(_ sender: AnyObject) {
//        KatsanaAPI.sharedInstance.test()
//        let test =  KatsanaAPI.sharedInstance.API.resource("vehicles");
//        print(test)
    }
}

