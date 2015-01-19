//
//  ViewController.swift
//  DejikoCharge
//
//  Created by numa08 on 2015/01/06.
//  Copyright (c) 2015年 numanuma08. All rights reserved.
//

import UIKit
import DejikoProvider
import AsyncImageView

class ViewController: UIViewController {

    @IBOutlet weak var contentImageView: AsyncImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentImageView.contentMode = .ScaleAspectFit
        let operation = NSBlockOperation {
            let result = PixivDejikoProvider().requestDejiko(PixivDejikoRequest(page: 1))
            let content = result.map{$0.success{$0.content}}.first
            if let con = content {
                if let u = con {
                    self.contentImageView.contentURL = NSURL(string: u)
                }
            }
            for r in result {
                switch(r){
                case let .Success(resp):
                    NSLog("\(resp)")
                case let .Error(e):
                    NSLog("\(e.localizedDescription)")
                }
            }
        }
        NSOperationQueue().addOperation(operation)
    }


}

