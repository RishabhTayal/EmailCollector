//
//  ViewController.m
//  EmailCollector
//
//  Created by Rishabh Tayal on 8/12/15.
//  Copyright (c) 2015 Rishabh Tayal. All rights reserved.
//

import UIKit
import MessageUI
import MBProgressHUD
import UITableView_NXEmptyView

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, SelectorDelegate, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var list: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.searchBar.text = NSUserDefaults.standardUserDefaults().stringForKey("domain")
        if let rows = delegate.getLocalArray() {
            self.list = rows
            self.addNavigationItems()
            self.tableView.reloadData()
        } else {
            self.list = []
            let label = UILabel(frame: self.tableView.frame)
            label.text = "Start searching for a company name."
            label.textAlignment = .Center
            label.textColor = UIColor.lightGrayColor()
            self.tableView.nxEV_emptyView = label
            self.tableView.nxEV_hideSeparatorLinesWhenShowingEmptyView = true
            //           makeAPICallForDomain()
        }
    }
    
    func makeAPICallForDomain(domain: String?) {
        self.list = []
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        ServiceCaller.getEmails(withOffset: 0, completionBlock: { (result, error) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            if result != nil {
                let domainData = DomainData(dict: result as! NSDictionary)
                let emails = domainData.emails
                for email in emails {
                    self.list.append(email.value!)
                }
                NSUserDefaults.standardUserDefaults().setObject(domainData.results, forKey: "total")
                NSUserDefaults.standardUserDefaults().synchronize()
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                delegate.saveAsFile(self.list)
                self.addNavigationItems()
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            }
        })
    }
    
    func addNavigationItems() {
        self.title = "\(self.list.count)(Total: \(NSUserDefaults.standardUserDefaults().objectForKey("total")!))"
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: MFMailComposeViewController Delegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: UISearchBar Delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        NSUserDefaults.standardUserDefaults().setObject(searchBar.text, forKey: "domain")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.makeAPICallForDomain(searchBar.text)
    }
}