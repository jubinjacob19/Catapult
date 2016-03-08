//
//  NetworkOperation.swift
//  Working Title
//
//  Created by Jubin Jacob on 12/02/16.
//  Copyright © 2016 J. All rights reserved.
//

import UIKit

class NetworkOperation: AsyncOperation {
    var sessionTask : NSURLSessionDataTask?
    
    override func cancel() {
        if(executing) {
            print("session cancelled")
            self.sessionTask?.cancel()
        }
        super.cancel()
    }
    
    func error(code:Int, userInfo:[NSObject : AnyObject])->NSError {
        return NSError(domain: "com.j.catapult", code: code, userInfo: userInfo)
    }
    
}
