//
//  ViewController.swift
//  LayoutLoopHunter
//
//  Created by rsrbk on 01/07/2019.
//  Copyright (c) 2019 rsrbk. All rights reserved.
//

import UIKit
import LayoutLoopHunter

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        LayoutLoopHunter.setUp(for: view) {
            print("Hello, world")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setNeedsLayout() // loop creation
    }

}

