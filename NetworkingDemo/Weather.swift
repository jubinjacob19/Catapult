//
//  Weather.swift
//  NetworkingDemo
//
//  Created by Jubin Jacob on 24/01/16.
//  Copyright © 2016 J. All rights reserved.
//

import Foundation

protocol Weather {
    init(baseURL:String, location:String)
    func weatherResponse(completionHandler:Completion)
}
