//
//  YQCollectionCellView.swift
//  Interval Timer
//
//  Created by Yu Qiao on 11/3/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

import Foundation

class YQCollectionCellView: UICollectionViewCell, UITableViewDataSource{
    
    @IBOutlet weak var timerDetailTable: UITableView!
    @IBOutlet weak var downloadButton: YQButtonView!
    @IBOutlet weak var timerInfo: YQButtonView!
    
    var cellDetails:[String] = []{
        didSet{
           timerDetailTable.reloadData()
        }
    }
    
    var timerName: String = "timer name"
    
    let cellIdentifierArray = ["warmUpCell", "roundCell", "restCell", "coolDownCell", "cycleCell"]
    let cellText = ["Warm Up", "Round", "Rest", "Cool Down", "Cycle"]
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 5;
    }
    
    
    //table cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifierArray[indexPath.row]) as UITableViewCell
        cell.textLabel?.text = cellText[indexPath.row];
        cell.detailTextLabel?.text = cellDetails[indexPath.row];
        return cell
    }
    
    //section header
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return timerName
    }
}

class YQButtonView: UIButton {
    var indexPath:NSIndexPath?
}
