//
//  ReachablityOperation.swift
//  NetworkingDemo
//
//  Created by Jubin Jacob on 26/01/16.
//  Copyright © 2016 J. All rights reserved.
//

import SystemConfiguration
import Foundation

class ReachablityOperation: AsyncOperation {
    
    let host: NSURL
    
    
    init(host: NSURL) {
        self.host = host
    }
    
    override func main() {
        ReachabilityController.requestReachability(host) { reachable in
            self.isReachable = reachable
            self.completeOperation()
        }
    }
}

private class ReachabilityController {
    static var reachabilityRefs = [String: SCNetworkReachability]()
    
    static let reachabilityQueue = dispatch_queue_create("Operations.Reachability", DISPATCH_QUEUE_SERIAL)
    
    static func requestReachability(url: NSURL, completionHandler: (Bool) -> Void) {
        if let host = url.host {
            dispatch_async(reachabilityQueue) {
                var ref = self.reachabilityRefs[host]
                
                if ref == nil {
                    let hostString = host as NSString
                    ref = SCNetworkReachabilityCreateWithName(nil, hostString.UTF8String)
                }
                
                if let ref = ref {
                    self.reachabilityRefs[host] = ref
                    
                    var reachable = false
                    var flags: SCNetworkReachabilityFlags = []
                    if SCNetworkReachabilityGetFlags(ref, &flags) != false {
                        /*
                        Note that this is a very basic "is reachable" check.
                        Your app may choose to allow for other considerations,
                        such as whether or not the connection would require
                        VPN, a cellular connection, etc.
                        */
                        reachable = flags.contains(.Reachable)
                    }
                    completionHandler(reachable)
                }
                else {
                    completionHandler(false)
                }
            }
        }
        else {
            completionHandler(false)
        }
    }
}


