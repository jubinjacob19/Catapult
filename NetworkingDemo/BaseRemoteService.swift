//
//  BaseRemoteService.swift
//  NetworkingDemo
//
//  Created by Jubin Jacob on 01/10/15.
//  Copyright © 2015 J. All rights reserved.
//

import UIKit

struct WebServiceResponse {
    var result:AnyObject?
    var error : NSError?
}

typealias Completion = (response : WebServiceResponse)->Void

class BaseRemoteService: NSObject {
    let httpGet = "GET"
    let httpPost = "POST"
    let kContentType = "Content-Type";
    let kJsonHeader = "application/json";
    let kSuccessStatusCode : Int = 200
    let errorDomain = "com.j.remoteservice"
    private let host : String
    private let basePath : String
    private var httpScheme = "http"
    init(host hostname:String,basePath : String, secure : Bool = false) {
        self.host = hostname
        self.basePath = basePath
        if(secure) {
            self.httpScheme = "https"
        }
        super.init()
    }
    
    func GET(path name:String, params:Dictionary<String,String>, completion:Completion)->Cancellable {
        let urlRequest : NSMutableURLRequest = NSMutableURLRequest(URL: self.URL(name, params: params))
        urlRequest.HTTPMethod = httpGet
        urlRequest.setValue(kJsonHeader, forHTTPHeaderField: kContentType)
        return genericHTTPRequest(urlRequest, completion: completion)
    }
    
    func POST(path:String, queryParams:[String:String]?, postParams:[String:AnyObject], completion:Completion)->Cancellable {
        let urlRequest : NSMutableURLRequest = NSMutableURLRequest(URL: self.URL(path, params: queryParams))
        urlRequest.HTTPMethod = httpPost
        urlRequest.setValue(kJsonHeader, forHTTPHeaderField: kContentType)
        urlRequest.HTTPBody = self.jsonData(postParams).data
        return genericHTTPRequest(urlRequest, completion: completion)
        
    }
    
    func genericHTTPRequest(urlRequest:NSURLRequest,completion:Completion)->Cancellable {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.allowsCellularAccess = true
        sessionConfig.HTTPMaximumConnectionsPerHost = 1
        sessionConfig.timeoutIntervalForRequest = 2.0
        let session:NSURLSession = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        let dataTask = session.dataTaskWithRequest(urlRequest) {(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if(data != nil && error == nil) {
                let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
                if(statusCode == self.kSuccessStatusCode) {
                    completion(response: self.nativeObject(data!))
                } else {
                    guard let userInfo:[NSObject : AnyObject] = self.nativeObject(data!).result as? [NSObject : AnyObject] else {
                        completion(response: WebServiceResponse(result: nil, error: self.error(statusCode, userInfo:["data":"parsing error"])))
                        return
                    }
                    let error:NSError = (self.error(statusCode, userInfo: userInfo))
                    completion(response: WebServiceResponse(result: nil, error: error))
                }
            } else if(error != nil) {
                completion(response: WebServiceResponse(result: nil, error: error))
            }
            session.finishTasksAndInvalidate()
            }
        dataTask.resume()
    
        return dataTask
    }
    
    func URL(path:String, params:[String:String]?) -> NSURL {
        let components : NSURLComponents = NSURLComponents()
        components.scheme = httpScheme
        components.host = self.host
        components.path = self.basePath + path
        if let queryParams = params {
            if #available(iOS 8.0, *) {
                components.queryItems = queryParams.map { (key, value) -> NSURLQueryItem in
                    return NSURLQueryItem(name: key, value: value)
                }
                return components.URL!
            } else {
                let queryString = "?" + queryParams.map({ (key, value) -> String in
                    return key + "=" + value
                }).joinWithSeparator("&")
                guard let interimUrl = components.URL?.absoluteString else {preconditionFailure("invalid irl")}
                return NSURL(string: interimUrl + queryString)!
            }
        } else {
            return components.URL!
        }
    }
    
    func nativeObject(data:NSData)->WebServiceResponse {
        do
        {
            let jsonObject:AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            return WebServiceResponse(result: jsonObject, error: nil)
            
        } catch let caught as NSError {
            return WebServiceResponse(result: nil, error: caught)
        } catch {
            let error: NSError = NSError(domain:errorDomain, code: 1, userInfo: nil)
            return WebServiceResponse(result: nil, error: error)
        }
    }
    
    func jsonData(jsonObject:AnyObject)->(data:NSData?, error:NSError?) {
        do
        {
            let jsonData:NSData? = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: NSJSONWritingOptions.PrettyPrinted)
            return (jsonData,nil)
        } catch let caught as NSError {
            return (nil,caught)
        } catch {
            let error: NSError = NSError(domain:errorDomain, code: 2, userInfo: nil)
            return (nil,error)
        }
    }
    
    func error(code:Int, userInfo:[NSObject : AnyObject])->NSError {
        return NSError(domain: errorDomain, code: code, userInfo: userInfo)
    }
    
}
