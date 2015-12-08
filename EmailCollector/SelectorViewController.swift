//
//  SelectorViewController.swift
//  EmailCollector
//
//  Created by Tayal, Rishabh on 12/8/15.
//  Copyright © 2015 Rishabh Tayal. All rights reserved.
//

import UIKit

protocol SelectorDelegate {
    func didSelect()
}

class SelectorViewController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var minLabel: UILabel!
    @IBOutlet var selectedLabel: UILabel!
    @IBOutlet var slider: UISlider!
    
    var delegate: SelectorDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.totalLabel.text = "\(NSUserDefaults.standardUserDefaults().stringForKey("total"))"
        self.slider.maximumValue = Float(totalLabel.text!)!
        self.slider.minimumValue = Float(appDelegate.getLocalArray()!.count)
        self.minLabel.text = "\(slider.minimumValue)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderChanged(sender: AnyObject) {
        var value: Int = Int(self.slider.value)
        let stepSize: Int = 100
        value = (value - value % stepSize)
        self.slider.value = Float(value)
        self.selectedLabel.text = "\(slider.value)"
    }
    
    @IBAction func doneCliced(sender: AnyObject) {
        let currentOffset: Int = Int(slider.minimumValue) / 100
        let newOffset: Int = Int(slider.value) / 100
        UIAlertView(title: "Warning", message: "This will make \(newOffset - currentOffset) API calls", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Ok").show()
    }
    
    //MARK: UIAlertView Delegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            let currentOffset: Int = Int(slider.minimumValue) / 100
            let newOffset: Int = Int(slider.value) / 100
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            var list: [AnyObject] = appDelegate.getLocalArray()!
            for var i = currentOffset; i <= newOffset; i++ {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() -> Void in
                    if let data: NSData = NSData(contentsOfURL: NSURL(string: "https://api.emailhunter.co/v1/search?domain=illinois.edu&offset=\(i)&api_key=80af57421ced39fbe8de5ae7e2605565e598f484")!) {
                        do {
                            let result: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                            list = (result["emails"] as! NSDictionary)["value"] as! [AnyObject]
                            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                                if i == newOffset {
                                    appDelegate.saveAsFile(list)
                                    self.navigationController!.popViewControllerAnimated(true)
                                    if (self.delegate != nil) {
                                        self.delegate.didSelect()
                                    }
                                }
                            })
                        } catch {
                            
                        }
                    }
                })
            }
        }
        else {
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
}
