//
//  YQCollectionViewController.swift
//  Interval Timer
//
//  Created by Yu Qiao on 10/27/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

import UIkit


class YQCollectionViewController: UICollectionViewController{

    var timerList:[timerForDisplay] = []  //store the timer on the cloud
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var timerJosn: Array<AnyObject> = []
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidAppear(animated: Bool) {
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        //indicator.startAnimating()
        
        var URL = "http://0.0.0.0:8000/timers"
        var request = HTTPTask()
        request.responseSerializer = JSONResponseSerializer()
        request.GET(URL, parameters: nil, success: {(response: HTTPResponse) in
            if response.responseObject != nil{
                self.timerJosn = response.responseObject as Array<AnyObject>
                
                var timer: timerForDisplay
                var tD: Dictionary<String, AnyObject>
                for t in self.timerJosn{
                    tD = t as Dictionary<String, AnyObject>
                    timer = timerForDisplay()
                    timer.name = tD["name"] as String
                    timer.roundLength = tD["roundLength"] as Int
                    timer.restLength = tD["restLength"] as Int
                    timer.coolDownLength = tD["cooldownLength"] as Int
                    timer.warmUpLength = tD["warmUpLength"] as Int
                    timer.cycle = tD["cycle"] as Int
                    timer.creationTime = tD["creationTime"] as String
                    
                    self.timerList.append(timer)
                }
                
                //UI change needs to be made in UI thread (main thread)
                dispatch_async(dispatch_get_main_queue(), {
                    // Your code to run on the main queue/thread
                    self.indicator.stopAnimating()
                    self.indicator.removeFromSuperview()
                    self.collectionView.reloadData()
                });
                
                
            }
            }, failure: {(error: NSError, response: HTTPResponse?) in
                //handle error
        })
    }
    
    //how many cells in a section
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return timerJosn.count;
    }
    
    //which cell?
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        var cell: YQCollectionCellView = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as YQCollectionCellView;
        var timerInfo = "Name: " + timerList[indexPath.row].name + "\n"
        timerInfo += "Round Timer: " + String(timerList[indexPath.row].roundLength) + "\n"
        timerInfo += "Rest Time: " + String(timerList[indexPath.row].restLength) + "\n"
        timerInfo += "Creation Time: " + timerList[indexPath.row].creationTime
        
        cell.nameCell.text = timerInfo
        cell.downloadButton.indexPath = indexPath
        return cell;
    }
    
    //how many section?
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    //when get it button is clicked
    @IBAction func downloadTimer(sender: YQButtonView) {
        var indexPath:NSIndexPath? = sender.indexPath
        
        if((indexPath) != nil){
            println(indexPath?.row)
        }
    }
    
    //when side menu button is clicked
    @IBAction func toggleSizeMenu(sender: AnyObject) {
        self.toggleSideMenuView()
    }
}

class timerForDisplay{
    var name: String = ""
    var warmUpLength: Int = 0
    var roundLength: Int = 0
    var restLength: Int = 0
    var cycle: Int = 0
    var coolDownLength: Int = 0
    var creationTime: String = ""

}

