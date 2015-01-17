//
//  ViewController.swift
//  DejikoCharge
//
//  Created by numa08 on 2015/01/06.
//  Copyright (c) 2015年 numanuma08. All rights reserved.
//

import UIKit
import DejikoProvider

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let operation = NSBlockOperation {
            let result = PixivDejikoProvider().requestDejiko(PixivDejikoRequest(page: 0))
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

