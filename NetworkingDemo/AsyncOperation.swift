//
//  AsyncOperation.swift
//  NetworkingDemo
//
//  Created by Jubin Jacob on 25/01/16.
//  Copyright © 2016 J. All rights reserved.
//

import UIKit

infix operator |> { }
func |> (operation1: NSOperation, operation2: NSOperation) {
    operation2.addDependency(operation1)
}

protocol ChecksReachabliy {
    var isReachable : Bool {get set}
}


class AsyncOperation: NSOperation,ChecksReachabliy {

    var isReachable = true // is reset in the reachablity check operation completion block
    
    override var asynchronous: Bool {
        return true
    }
    
    override init() {
        
    }
    
    private var _executing: Bool = false
    override var executing: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValueForKey("isExecuting")
                _executing = newValue
                didChangeValueForKey("isExecuting")
            }
        }
    }
    
    private var _finished: Bool = false;
    override var finished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValueForKey("isFinished")
                _finished = newValue
                didChangeValueForKey("isFinished")
            }
        }
    }
    
    func completeOperation () {
        executing = false
        finished = true
    }
    
    override func start()
    {
        if cancelled {
            finished = true
            return
        }
        
        executing = true
        
        main()
    }
    
    override func cancel() {
        super.cancel()
        if(executing) {
            self.completeOperation()
        }
    }
    

}

extension String {
    var length: Int {
        return characters.count
    }
}
