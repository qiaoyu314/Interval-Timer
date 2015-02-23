//
//  YQShareViewController.swift
//  Interval Timer
//
//  Created by Yu Qiao on 12/13/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

import Foundation

class YQShareViewController:UIViewController{
    var timer: Timer?
    
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBAction func shareTime(sender: UIButton) {
        //validate the user's input
        if descriptionField.text.isEmpty{
            var alert = UIAlertController(title: nil, message: "Please enter the description of the timer.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: false, nil)
            return
        }
        
        if timer != nil{
            let params = ["timer":[
                "name": timer!.name!,
                "warmUpLength":timer!.warmUpLength!,
                "roundLength": timer!.roundLength!,
                "restLength": timer!.restLength!,
                "coolDownLength": timer!.cooldownLength!,
                "cycle": timer!.cycle!,
                "description": descriptionField.text!]
            ]
            
            request(.POST, httpDomain, parameters: params).responseJSON{(req, res, json, err) in
                var message: String;
                if err == nil{
                    message = "You timer has been shared with everyone."
                }else{
                    message = "Fail to share this timer."
                }
                var alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: {(_)->Void in
                    self.navigationController?.popViewControllerAnimated(true)
                    return
                })
                alert.addAction(OKAction)
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                
            }
        }
    }
}