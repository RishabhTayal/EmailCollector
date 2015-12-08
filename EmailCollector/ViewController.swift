//
//  ViewController.m
//  EmailCollector
//
//  Created by Rishabh Tayal on 8/12/15.
//  Copyright (c) 2015 Rishabh Tayal. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, SelectorDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var list: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let rows = delegate.getLocalArray() {
            self.list = rows
            self.addNavigationItems()
            self.tableView.reloadData()
        }
        else {
            self.list = []
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() -> Void in
                let data: NSData? = NSData(contentsOfURL: (NSURL(string: "https://api.emailhunter.co/v1/search?domain=illinois.edu&api_key=80af57421ced39fbe8de5ae7e2605565e598f484")!))!
                if data != nil {
                    do {
                        let result: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                        self.list = (result["emails"] as! NSArray).valueForKey("value") as! [AnyObject]
                        print(result)
                        let resultValue = result["results"]
                        NSUserDefaults.standardUserDefaults().setObject(resultValue, forKey: "total")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        //                [self saveAsFileAction:nil];
                        delegate.saveAsFile(self.list)
                        dispatch_async(dispatch_get_main_queue(), {() -> Void in
                            self.addNavigationItems()
                            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                        })
                    } catch {
                        
                    }
                }
            })
        }
    }
    
    func addNavigationItems() {
        self.title = "\(self.list.count)(Total: \(NSUserDefaults.standardUserDefaults().objectForKey("total"))"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareClicked:")
        //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Load More" style:UIBarButtonItemStylePlain target:self action:@selector(loadAllClicked:)];
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func shareClicked(sender: AnyObject) {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.saveAsFile(self.list)
        //    [self saveAsFileAction:nil];
        let mail: MFMailComposeViewController = MFMailComposeViewController()
        mail.setSubject("Emails collected")
        mail.mailComposeDelegate = self
        let csvData: NSData = NSData(contentsOfFile: delegate.dataFilePath())!
        mail.addAttachmentData(csvData, mimeType: "text/csv", fileName: "Emails.csv")
        self.presentViewController(mail, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier!.isEqual("selectorSegue") {
            let selecVC: SelectorViewController = segue.destinationViewController as! SelectorViewController
            selecVC.delegate = self
        }
    }
    
    func didSelect() {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.list = delegate.getLocalArray()!
        self.tableView.reloadData()
        self.addNavigationItems()
    }
    
    //MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as! TableViewCell
        let emailObject: AnyObject = self.list[indexPath.row]
        //    cell.textLabel.text = emailObject;
        cell.emailLabel.text = emailObject as? String
        cell.numberLabel.text = "\(indexPath.row + 1)"
        return cell
    }
 
    //MARK: MFMailComposeViewController Delegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}