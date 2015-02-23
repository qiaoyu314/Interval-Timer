//
//  YQCollectionViewController.swift
//  Interval Timer
//
//  Created by Yu Qiao on 10/27/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//


class YQCollectionViewController: UICollectionViewController{
    //outlets
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    //properties
    var managedObjectContext:NSManagedObjectContext?
    var timerList:[timerForDisplay] = []  //store the timer on the cloud
    var fromIndex: Int = 0  //the starting index of the timers for next loading. used for incremental load
    
    private let loadSize = 20
    private var loadFrom: String = ""
    private var hasMoreData = true
    
    override func viewDidAppear(animated: Bool) {
        if let scrollView = view as? UIScrollView{
            scrollView.scrollsToTop = true
        }
        
        loadTimers()
    }
    
    //how many cells in a section
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return timerList.count;
    }
    
    //which cell?
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        var cell: YQCollectionCellView = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as YQCollectionCellView;
        let timerInfo = timerList[indexPath.row]
        
        var timerDetailIntArray = [timerInfo.warmUpLength, timerInfo.roundLength, timerInfo.restLength, timerInfo.coolDownLength, timerInfo.cycle]
        var timerDetailStringArray: [String] = timerDetailIntArray.map{
            if $0==nil{
                return "0"
            }else{
                return "\($0!)"
            }
        }
        cell.timerName = timerInfo.name ?? "Timer Name"
        cell.cellDetails = timerDetailStringArray
        cell.downloadButton.indexPath = indexPath
        cell.timerInfo.indexPath = indexPath
        
        //load more timer if we has reach the end
        if indexPath.row == self.timerList.count-1{
            loadTimers();
        }
        
        return cell;
    }
    
    //how many section?
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    
    
    //when Download button is clicked
    @IBAction func downloadTimer(sender: YQButtonView) {
        
        //create a new timer and save it locally
        var newTimer:Timer = NSEntityDescription.insertNewObjectForEntityForName("Timer", inManagedObjectContext: managedObjectContext!) as Timer
        
        //set the properties
        let selectedTimer = timerList[(sender.indexPath?.row)!]
        newTimer.name = selectedTimer.name ?? ""
        newTimer.warmUpLength = selectedTimer.warmUpLength ?? 0
        newTimer.roundLength = selectedTimer.roundLength ?? 0
        newTimer.restLength = selectedTimer.restLength ?? 0
        newTimer.cycle = selectedTimer.cycle ?? 0
        
        var error: NSError?
        var message: String
        managedObjectContext?.save(&error)
        if error == nil{
            message = "This timer is saved into your timer list successfully."
        }else{
            message = "Failed to save the timer."
        }
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        presentViewController(alert, animated: false) {
        }
    }
    
    //when side menu button is clicked
    @IBAction func toggleSizeMenu(sender: AnyObject) {
        self.toggleSideMenuView()
    }
    
    //refresh the timer list
    @IBAction func refresh(sender: AnyObject) {
        loadFrom = ""
        timerList.removeAll(keepCapacity: false);
        loadTimers()
        self.collectionView?.setContentOffset(CGPointZero, animated: true)
    }
    
    
    @IBAction func showDetail(sender: YQButtonView) {
        var indexPath:NSIndexPath? = sender.indexPath
        if(indexPath != nil){
            var alertController:UIAlertController
            if let description = self.timerList[(indexPath?.row)!].description{
                alertController = UIAlertController(title: "Description", message: description, preferredStyle: .Alert)
                
            }else{
                alertController = UIAlertController(title: "Description", message: "No decription", preferredStyle: .Alert)
            }
            
            let OKaction = UIAlertAction(title: "OK", style: .Default){(_) in
                
            }
            alertController.addAction(OKaction)
            
            self.presentViewController(alertController, animated: true, completion: {})
        }
    }
    
    func loadTimers(){
        if !hasMoreData {
            return
        }
        indicator.startAnimating()
        let param = ["loadParams":["loadSize": loadSize, "loadFrom": loadFrom]]
        request(.GET, httpDomain, parameters: param)
            .responseJSON { (_, res, data, err) in
                if err == nil{
                    let data = JSON(data!)
                    if let dataArray = data["timers"].asArray{
                        if dataArray.count < self.loadSize{
                            self.hasMoreData = false;
                        }
                        for(index, value) in data["timers"]{
                            var timer = timerForDisplay()
                            timer.name = value["name"].asString
                            
                            if let warmUpLength = value["warmUpLength"].asInt{
                                timer.warmUpLength = warmUpLength
                            }else if let warmUpLength = value["warmUpLength"].asString{
                                timer.warmUpLength = warmUpLength.toInt()
                            }
                            if let roundLength = value["roundLength"].asInt{
                                timer.roundLength = roundLength
                            }else if let roundLength = value["roundLength"].asString{
                                timer.roundLength = roundLength.toInt()
                            }
                            if let restLength = value["restLength"].asInt{
                                timer.restLength = restLength
                            }else if let restLength = value["restLength"].asString{
                                timer.restLength = restLength.toInt()
                            }
                            if let coolDownLength = value["coolDownLength"].asInt{
                                timer.coolDownLength = coolDownLength
                            }else if let coolDownLength = value["coolDownLength"].asString{
                                timer.coolDownLength = coolDownLength.toInt()
                            }
                            if let cycle = value["cycle"].asInt{
                                timer.cycle = cycle
                            }else if let cycle = value["cycle"].asString{
                                timer.cycle = cycle.toInt()
                            }
                            if let description = value["description"].asString{
                                timer.description = description
                            }
                            self.timerList.append(timer)
                        }
                        
                        //update loadFrom
                        self.loadFrom = dataArray.last?["_id"].asString ?? ""
                    }
                    
                }else{
                    self.hasMoreData = false
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

class timerForDisplay{
    var name: String?
    var warmUpLength: Int?
    var roundLength: Int?
    var restLength: Int?
    var cycle: Int?
    var coolDownLength: Int?
    var creationTime: NSDate?
    var description: String?
}

