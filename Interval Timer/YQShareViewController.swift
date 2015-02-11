//
//  YQShareViewController.swift
//  Interval Timer
//
//  Created by Yu Qiao on 12/13/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

import Foundation

class YQShareViewController:UIViewController{
    var timer: Timer!;
    
    
    @IBAction func shareTimer(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
        let URL = "http://0.0.0.0:8000/timers"
        var request = HTTPTask()
        let params: Dictionary<String,AnyObject> = ["timer":[
            "name": timer.name,
            "warmUpLength":timer.warmUpLength,
            "roundLength": timer.roundLength,
            "restLength": timer.restLength,
            "cooldownLength": timer.cooldownLength,
            "cycle": timer.cycle,
            "creationTime": NSDate(timeIntervalSinceNow: 0)]
        ]
        request.POST(URL, parameters: params, success: {(response: HTTPResponse) in
            if response.statusCode == 200 {
                dispatch_async(dispatch_get_main_queue(),{
                    //self.navigationController?.popViewControllerAnimated(true);
                });
            }
            },failure: {(error: NSError, response: HTTPResponse?) in
        })
    }
}