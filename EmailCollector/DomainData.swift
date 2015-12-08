//
//  DomainData.swift
//  EmailCollector
//
//  Created by Tayal, Rishabh on 12/8/15.
//  Copyright © 2015 Rishabh Tayal. All rights reserved.
//

import Foundation

class DomainData: AnyObject {

    var domain: String?
    var emails: [EmailData] = []
    var offset: NSNumber?
    var pattern: String?
    var results: NSNumber?
    var status: Bool?
    var webmail: Bool?
    
    init(dict: NSDictionary) {
        domain = dict["domain"] as? String
        for emailDict in dict["emails"] as! [NSDictionary] {
            let email = EmailData(emailDict: emailDict)
            emails.append(email)
        }
        offset = dict ["offset"] as? NSNumber
        pattern = dict["pattern"] as? String
        results = dict["results"] as? NSNumber
        status = dict["status"] as? Bool
        webmail = dict["webmail"] as? Bool
    }
}
