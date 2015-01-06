//
//  DejikoProvider.swift
//  DejikoCharge
//
//  Created by numa08 on 2015/01/06.
//  Copyright (c) 2015年 numanuma08. All rights reserved.
//

import Foundation
public protocol DejikoProvider {
    func requestDejiko(request : DejikoRequest) -> [DejikoRequestResult]
}

public protocol DejikoRequest {}
public protocol DejikoResponse {
    var content : String { get }
}

public enum DejikoRequestResult{
    case Success(DejikoResponse)
    case Error(NSError)
}
