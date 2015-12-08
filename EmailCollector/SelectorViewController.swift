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
        let resultValue = NSUserDefaults.standardUserDefaults().objectForKey("total")
        self.totalLabel.text = "\(resultValue!)"
        self.slider.maximumValue = totalLabel.text!.floatValue
        self.slider.minimumValue = Float(appDelegate.getLocalArray()!.count)
        self.minLabel.text = "\(slider.minimumValue)"
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
            let currentOffset: Int = Int(Int(slider.minimumValue) / 100)
            let newOffset: Int = Int(Int(slider.value) / 100)
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            var list: [AnyObject] = appDelegate.getLocalArray()!
            for var i = currentOffset; i <= newOffset; i++ {
                
                ServiceCaller.getEmails(withOffset: i, completionBlock: { (result, error) -> Void in
                    let domainData = DomainData(dict: result as! NSDictionary)
                    let emails = domainData.emails
                    for email in emails {
                        list.append(email.value!)
                    }
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        if i == newOffset {
                            appDelegate.saveAsFile(list)
                            self.navigationController!.popViewControllerAnimated(true)
                            if (self.delegate != nil) {
                                self.delegate.didSelect()
                            }
                        }
                    })
                })
            }
        } else {
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
}
