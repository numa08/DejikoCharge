//
//  GridView.swift
//  GridView
//
//  Created by numa08 on 2015/01/27.
//  Copyright (c) 2015年 numanuma08. All rights reserved.
//

import UIKit
public class GridView: UIView{

    @IBOutlet weak var contentScrollView: UIScrollView!
    public weak var dataSource: GridViewDataSource?
    public weak var delegate: GridViewDelegate?
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        self.frame = frame
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func initialize() {
        if(self.subviews.count == 0 ){
            let view = NSBundle.mainBundle().loadNibNamed("GridView", owner: nil, options: nil)[0] as UIView
            self.addSubview(view)
        }
    }
    
    private var numberOfRow: UInt {
        if let ds = self.dataSource {
            return ds.gridViewNumberOfRow(self)
        }
        return 0
    }

    private func numberOfColumnAtRow(row: UInt) -> UInt {
        if let ds = self.dataSource {
            return ds.gridView(self, numberOfColumnAtRow: row)
        }
        return 0
    }
    
    private func viewAtIndexPath(indexPath: NSIndexPath, withFrame frame: CGRect) -> UIView {
        if let ds = self.dataSource {
            return ds.gridView(self, viewAtIndexPath: indexPath, withFrame: frame)
        }
        return UIView()
    }
}
@objc public protocol GridViewDataSource: class{
    func gridViewNumberOfRow(gridview: GridView) -> UInt
    func gridView(gridview: GridView, numberOfColumnAtRow row: UInt) -> UInt
    func gridView(gridView: GridView, viewAtIndexPath indexPath:NSIndexPath, withFrame frame: CGRect) -> UIView
}
@objc public protocol GridViewDelegate: class{}
