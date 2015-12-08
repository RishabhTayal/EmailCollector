//
//  ServiceCaller.swift
//  EmailCollector
//
//  Created by Tayal, Rishabh on 12/8/15.
//  Copyright © 2015 Rishabh Tayal. All rights reserved.
//

import UIKit

typealias CompletionBlock = (result: AnyObject?, error: NSError?) -> Void

class ServiceCaller: NSObject {
    
    class func getEmails(withOffset offset: Int, completionBlock: CompletionBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() -> Void in
            let data: NSData? = NSData(contentsOfURL: NSURL(string: "https://api.emailhunter.co/v1/search?domain=illinois.edu&offset=\(offset)&api_key=80af57421ced39fbe8de5ae7e2605565e598f484")!)!
            if data != nil {
                do {
                    let result: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    completionBlock(result: result, error: nil)
                    ///asdfasdfsd
                } catch {
                    completionBlock(result: nil, error: nil)
                }
            }
        })
        
    }
    
}
