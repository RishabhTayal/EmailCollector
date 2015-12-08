//
//  EmailData.swift
//  EmailCollector
//
//  Created by Tayal, Rishabh on 12/8/15.
//  Copyright © 2015 Rishabh Tayal. All rights reserved.
//
import Foundation

class EmailData: AnyObject {

    var sources: [AnyObject]?
    var type: String?
    var value: String?
    
    init(emailDict: NSDictionary) {
        sources = emailDict["sources"] as? [AnyObject]
        type = emailDict["type"] as? String
        value = emailDict["value"] as? String
    }
}
