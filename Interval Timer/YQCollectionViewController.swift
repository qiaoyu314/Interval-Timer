//
//  YQCollectionViewController.swift
//  Interval Timer
//
//  Created by Yu Qiao on 10/27/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

import Alamofire

class YQCollectionViewController: UICollectionViewController{
    
    var timerList:[timerForDisplay] = []  //store the timer on the cloud
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var fromIndex: Int = 0  //the starting index of the timers for next loading
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        loadTimers(true)
    }
    
    //how many cells in a section
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return timerList.count;
    }
    
    //which cell?
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        var cell: YQCollectionCellView = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as YQCollectionCellView;
        var timerInfo = timerList[indexPath.row].name
        cell.nameCell.text = timerInfo
        cell.downloadButton.indexPath = indexPath
        cell.timerInfo.indexPath = indexPath
        return cell;
    }
    
    //how many section?
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    //when get it button is clicked
    @IBAction func downloadTimer(sender: YQButtonView) {
        var indexPath:NSIndexPath? = sender.indexPath
        
        if(indexPath != nil){
            println(indexPath?.row)
        }
    }
    
    //when side menu button is clicked
    @IBAction func toggleSizeMenu(sender: AnyObject) {
        self.toggleSideMenuView()
    }
    
    //refresh the timer list
    @IBAction func refresh(sender: AnyObject) {
        loadTimers(true)
    }
    
    
    @IBAction func showDetail(sender: YQButtonView) {
        var indexPath:NSIndexPath? = sender.indexPath
        var description: String = ""
        if(indexPath != nil){
            description = self.timerList[(indexPath?.row)!].description
        }
        let alertController = UIAlertController(title: "Description", message: description, preferredStyle: .Alert)
        let OKaction = UIAlertAction(title: "OK", style: .Default){(action) in
        
        }
        alertController.addAction(OKaction)
        
        self.presentViewController(alertController, animated: true, completion: {})
    }
    
    
    func loadTimers(fromZero: Bool){
        if fromZero{
            self.fromIndex = 0
        }
        indicator.startAnimating()
    
        let URL = "http://0.0.0.0:8000/timers"
        Alamofire.request(.GET, URL)
            .responseJSON { (_, _, data:AnyObject?, _) in
                let data = JSON(data!)
                for(index, value) in data["timers"]{
                    var timer = timerForDisplay()
                    timer.name = value["name"].asString!
                    
                    self.timerList.append(timer)
                }
                
                //UI change needs to be made in UI thread (main thread)
                dispatch_async(dispatch_get_main_queue(), {
                    self.indicator.stopAnimating()
                    self.indicator.hidden = true
                    self.collectionView?.reloadData()
                });
        }
    }
}
//
class timerForDisplay{
    var name: String = ""
    var warmUpLength: Int = 0
    var roundLength: Int = 0
    var restLength: Int = 0
    var cycle: Int = 0
    var coolDownLength: Int = 0
    var creationTime: NSDate?
    var description: String = ""
}

