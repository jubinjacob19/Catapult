//
//  Cancellable.swift
//  Catapult
//
//  Created by Jubin Jacob on 08/03/16.
//  Copyright © 2016 J. All rights reserved.
//

import Foundation

protocol Cancellable {
    func cancelRequest()
}

extension NSURLSessionDataTask : Cancellable {
    func cancelRequest() {
        self.cancel()
    }
}