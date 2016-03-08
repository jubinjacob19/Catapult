//
//  BaseNetworkManager.swift
//  Working Title
//
//  Created by Jubin Jacob on 28/01/16.
//  Copyright © 2016 J. All rights reserved.
//

import UIKit

private let sharedManager = NetworkManager()

class BaseNetworkManager: NSObject {
    private var myContext = 0
    class var sharedInstance: NetworkManager {
        return sharedManager
    }
    
    lazy var webServiceQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "WebService queue"
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    override init() {
        super.init()
        self.webServiceQueue.addObserver(self, forKeyPath: "operations", options: NSKeyValueObservingOptions.New, context: &myContext)
    }
    
    func cancelAllRequests() {
        self.webServiceQueue.cancelAllOperations()
    }
    
    func evaluateIfReachable(operation : AsyncOperation)->[NSOperation] {
        let reachablityOperation = ReachablityOperation(host: NSURL(string: "https://www.google.com")!)
        reachablityOperation |> operation
        self.webServiceQueue.addOperations([reachablityOperation,operation], waitUntilFinished: false)
        reachablityOperation.completionBlock = { [weak operation,weak reachablityOperation] in // will cause memmory leak if not used!!
            operation?.isReachable = reachablityOperation!.isReachable
        }
        return [operation,reachablityOperation]
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            if object as? NSOperationQueue == self.webServiceQueue && keyPath == "operations" {
                if self.webServiceQueue.operationCount == 0 {
                    
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    deinit {
        self.webServiceQueue.removeObserver(self, forKeyPath: "operations", context: &myContext)
    }

}
