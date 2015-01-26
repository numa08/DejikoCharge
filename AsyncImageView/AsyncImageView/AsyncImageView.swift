//
//  AsyncImageView.swift
//  AsyncImageView
//
//  Created by numa08 on 2015/01/19.
//  Copyright (c) 2015年 numanuma08. All rights reserved.
//

import UIKit

public protocol AsyncImageViewHandler {
    func imageViewDidLoadImage(imageView : AsyncImageView) -> ()
    func imageView(imageView : AsyncImageView, didFailLoadImage : NSError) -> ()
}

public class AsyncImageView: UIImageView {

    class var operationQueue : NSOperationQueue {
        struct Static {
            static let operationQueue : NSOperationQueue = {
                let queue = NSOperationQueue()
                queue.name = "asyncimageview.operationqueue"
                return queue
            }()
        }
        return Static.operationQueue
    }
    
    public var handler : AsyncImageViewHandler?

    public var contentURL : NSURL? {
        didSet {
            self.contentURL.map{self.loadImage($0)}
        }
    }

    private func loadImage(URL : NSURL) {
        let operation = NSBlockOperation {
            let request = NSURLRequest(URL: URL)
            var response : NSURLResponse? = nil
            var error : NSError? = nil
            let body = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error: &error)
            if let e = error {
                self.handler?.imageView(self, didFailLoadImage: e)
                return
            }
            
            let statusCode = (response? as? NSHTTPURLResponse)?.statusCode ?? -1
            if statusCode != 200 {
                let e = self.error(-1, description: "http status is \(statusCode)")
                self.handler?.imageView(self, didFailLoadImage: e)
                return
            }

            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                let image = body.map{UIImage(data: $0)}
                image.map{self.image = $0}
                self.handler?.imageViewDidLoadImage(self)
            })
        }
        AsyncImageView.operationQueue.addOperation(operation)
    }
    
    
    private func error(code : Int, description : String) -> NSError {
        return NSError(domain: "net.numa08.asyncimageview", code: code, userInfo: [NSLocalizedDescriptionKey : description])
    }
}
