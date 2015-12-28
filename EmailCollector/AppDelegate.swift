//
//  AppDelegate.m
//  EmailCollector
//
//  Created by Rishabh Tayal on 8/12/15.
//  Copyright (c) 2015 Rishabh Tayal. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        Fabric.with([Crashlytics()])
        return true
    }
    
    func getLocalArray() -> [AnyObject] {
        do {
            let objects: AnyObject = try String(contentsOfFile: self.dataFilePath())
            let rows: [AnyObject] = objects.componentsSeparatedByString(", \n")
            return rows
        } catch {
            
        }
        return []
    }
    
    func saveAsFile(array: [AnyObject]) {
        NSFileManager.defaultManager().createFileAtPath(self.dataFilePath(), contents: nil, attributes: nil)
        let writeString: NSMutableString = NSMutableString(capacity: 0)
        //don't worry about the capacity, it will expand as necessary
        for var i = 0; i < array.count; i++ {
            if i == array.count - 1 {
                writeString.appendString(array[i] as! String)
            } else {
                writeString.appendString("\(array[i]), \n")
            }
        }
        //Moved this stuff out of the loop so that you write the complete string once and only once.
        NSLog("writeString :%@", writeString)
        let handle = NSFileHandle(forWritingAtPath: self.dataFilePath())
        //say to handle where's the file fo write
        //    [handle truncateFileAtOffset:[handle seekToEndOfFile]];
        //position handle cursor to the end of file
        handle?.writeData(writeString.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    func dataFilePath() -> String {
        var paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory: String = paths[0] as! String
//        return documentsDirectory.stringByAppendingString("myfile.csv")
        return (documentsDirectory as NSString).stringByAppendingPathComponent("myfile.csv")
    }
}