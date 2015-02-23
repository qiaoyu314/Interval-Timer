//
//  YQNewNavigationController.swift
//  Interval Timer
//
//  Created by Yu Qiao on 10/15/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

import UIKit


class YQNewNavigationController: ENSideMenuNavigationController{
    
    var managedObjectContext: NSManagedObjectContext?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var test = YQSideMenu()
        test.managedObjectContext = self.managedObjectContext
        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: test, menuPosition:.Left)

        //sideMenu?.delegate = self //optional
        sideMenu?.menuWidth = 180.0 // optional, default is 160
        //sideMenu?.bouncingEnabled = true
        
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)
    }
    
    
}

