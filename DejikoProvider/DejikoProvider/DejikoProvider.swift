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
    
    public func success<T>(act :DejikoResponse -> Optional<T>) -> Optional<T> {
        switch(self){
        case .Error: return nil
        case let .Success(x): return act(x)
        }
    }
    
    public func error<T>(act : NSError -> Optional<T>) -> Optional<T> {
        switch(self){
        case .Success: return nil
        case let .Error(e): return act(e)
        }
    }
    
    public func isSuccess() -> Bool {
        switch(self){
        case .Success: return true
        case .Error: return false
        }
    }
}
