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
        } else {
            self.list = []
            //TODO: make api call
            
            ServiceCaller.getEmails(withOffset: 0, completionBlock: { (result, error) -> Void in
                let domainData = DomainData(dict: result as! NSDictionary)
                let emails = domainData.emails
                for email in emails {
                    self.list.append(email.value!)
                }
                NSUserDefaults.standardUserDefaults().setObject(domainData.results, forKey: "total")
                NSUserDefaults.standardUserDefaults().synchronize()
                delegate.saveAsFile(self.list)
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    self.addNavigationItems()
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                })
            })
        }
    }
    
    func addNavigationItems() {
        self.title = "\(self.list.count)(Total: \(NSUserDefaults.standardUserDefaults().objectForKey("total"))"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareClicked:")
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