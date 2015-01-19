//
//  PixivDejikoProvider.swift
//  DejikoCharge
//
//  Created by numa08 on 2015/01/07.
//  Copyright (c) 2015年 numanuma08. All rights reserved.
//

import Foundation

public class PixivDejikoProvider: DejikoProvider {

    public init(){}
    
    public func requestDejiko(request: DejikoRequest) -> [DejikoRequestResult] {
        if let url = (request as? PixivDejikoRequest)?.query {
            return self.requestDejikoOverHTTP(url)
        } else {
            return [DejikoRequestResult.Error(self.error(-1, description: "Parameter Error"))]
        }
    }
    
    private func error(code : Int, description : NSString) -> NSError {return NSError(domain: "PixivDejikoProvider", code: code, userInfo: [NSLocalizedDescriptionKey : description])}
    
    private func requestDejikoOverHTTP(URL : NSURL) -> [DejikoRequestResult] {
        let request = NSURLRequest(URL: URL)
        var response : NSURLResponse? = nil
        var error : NSError? = nil
        let body = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error: &error)
        if let e = error {
            return [DejikoRequestResult.Error(e)]
        }
        
        let statusCode = (response? as? NSHTTPURLResponse)?.statusCode ?? -1
        if statusCode != 200 {
            let e = NSError(domain: "PixivDejikoProvider", code: -1, userInfo: [NSLocalizedDescriptionKey : "HTTP Status Code is \(statusCode)"])
            return [DejikoRequestResult.Error(e)]
        }
        
        var lines : [String]?

        if let b = body {
            if let csv = NSString(data: b, encoding: NSUTF8StringEncoding) {
                lines = csv.componentsSeparatedByString("\n").map{$0.description}
            }
        }
        
        func fix(f:((([String],Int,[DejikoRequestResult]) -> [DejikoRequestResult]),([String],Int,[DejikoRequestResult])) -> [DejikoRequestResult]) -> (([String],Int,[DejikoRequestResult]) -> [DejikoRequestResult]){
            var fix_f : (([String],Int,[DejikoRequestResult]) -> [DejikoRequestResult])!
            fix_f = {(l:[String],i:Int,r:[DejikoRequestResult]) -> [DejikoRequestResult] in return f(fix_f,(l,i,r))}
            return fix_f
        }
        
        let parser = fix { (f:(([String],Int,[DejikoRequestResult])->[DejikoRequestResult]), p :(l:[String],i:Int,r:[DejikoRequestResult])) -> [DejikoRequestResult] in
            if(p.i == p.l.count) {
                return p.r
            }
            
            let columns = p.l[p.i].componentsSeparatedByString(",")
            let (urlString, title) = (columns.get(9)?.stringByReplacingOccurrencesOfString("\"", withString: ""), columns.get(3)?.stringByReplacingOccurrencesOfString("\"", withString: ""))
            let res : DejikoRequestResult = {
                switch(urlString, title) {
                case (let a, .None):
                    let e = DejikoRequestResult.Error(self.error(-1, description: "Title Column Error"))
                    return e
                case (.None, let b):
                    let e = DejikoRequestResult.Error(self.error(-1, description: "URL Column Error"))
                    return e
                case (.None, .None):
                    let e = DejikoRequestResult.Error(self.error(-1, description: "Title and URL Column Error"))
                    return e
                case (let .Some(u), let .Some(t)):
                    let resp = NSURL(string: u) >>= {PixivDejikoResponse(imageURL: $0, title: t)} >>= {DejikoRequestResult.Success($0)}
                    if let rs = resp {
                        return rs
                    } else {
                        let e = DejikoRequestResult.Error(self.error(-1, description: "URL Format Error"))
                        return e
                    }
                default:
                    return DejikoRequestResult.Error(self.error(-1, description: "Column Error"))
                }
            }()
            var r = p.r
            r.append(res)
            let param = (p.l, p.i + 1, r)
            return f(param)
        }
        if let l = lines {
            return parser(l,0,[])
        } else {
            return [DejikoRequestResult.Error(self.error(-1, description: "Response Body Error"))]
        }
    }
}

public class PixivDejikoRequest: DejikoRequest {
    let QUERY_URL = NSURL(string: "http://spapi.pixiv.net/iphone/search.php?&s_mode=s_tag&word=%E3%81%A7%E3%81%98%E3%81%93")!
    
    let page : Int
    
    public init(page : Int) {
        self.page = page
    }
    
    public var query : NSURL? {
        get {
            return NSURL(string: QUERY_URL.description.stringByAppendingString("&p=\(self.page)"))
        }
    }
}

public class PixivDejikoResponse: DejikoResponse {
    let imageURL : NSURL
    public let title : String
    public var content : String {
        get{
            return imageURL.description
        }
    }
    
    init(imageURL : NSURL, title : String) {
        self.imageURL = imageURL
        self.title = title
    }
}

extension PixivDejikoResponse : DebugPrintable {
    public var debugDescription : String {
        get{return "\(title) : \(content)"}
    }
}

extension Array {
    
    func get(i : Int) -> T? {
        if i < count {
            return self[i]
        } else {
            return nil
        }
    }
}


infix operator >>= { associativity left precedence 95 }
func >>=<A, B> (a : Optional<A>, act : A -> Optional<B>) -> Optional<B> {
    switch(a){
    case .None: return nil
    case let .Some(x): return act(x)
    }
}
