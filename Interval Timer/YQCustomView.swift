//
//  YQCollectionCellView.swift
//  Interval Timer
//
//  Created by Yu Qiao on 11/3/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

import Foundation

class YQCollectionCellView: UICollectionViewCell{
    
    @IBOutlet weak var nameCell: UILabel!
    @IBOutlet weak var downloadButton: YQButtonView!
    @IBOutlet weak var timerInfo: YQButtonView!
}

class YQButtonView: UIButton {
    var indexPath:NSIndexPath?
}
