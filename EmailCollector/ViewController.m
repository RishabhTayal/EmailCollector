//
//  ViewController.m
//  EmailCollector
//
//  Created by Rishabh Tayal on 8/12/15.
//  Copyright (c) 2015 Rishabh Tayal. All rights reserved.
//

#import "ViewController.h"
#import <MessageUI/MessageUI.h>
#import "SelectorViewController.h"
#import "AppDelegate.h"
#import "TableViewCell.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, SelectorDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSMutableArray* list;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate* delegate = [UIApplication sharedApplication].delegate;
    NSArray* rows = delegate.getLocalArray;
    if (rows) {
        self.list = [NSMutableArray arrayWithArray:rows];
        [self addNavigationItems];
        [self.tableView reloadData];
    } else {
        self.list = [NSMutableArray new];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://api.emailhunter.co/v1/search?domain=illinois.edu&api_key=80af57421ced39fbe8de5ae7e2605565e598f484"]];
            if (data) {
                id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                self.list = [NSMutableArray arrayWithArray:[result[@"emails"] valueForKey:@"value"]];
                [[NSUserDefaults standardUserDefaults] setObject:result[@"results"] forKey:@"total"];
                [[NSUserDefaults standardUserDefaults] synchronize];
//                [self saveAsFileAction:nil];
                [delegate saveAsFile:self.list];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addNavigationItems];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }
        });
    }
}

-(void)addNavigationItems {
    self.title = [NSString stringWithFormat:@"%lu(Total: %@)", (unsigned long)self.list.count, [[NSUserDefaults standardUserDefaults] objectForKey:@"total"]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareClicked:)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Load More" style:UIBarButtonItemStylePlain target:self action:@selector(loadAllClicked:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)shareClicked:(id)sender {
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    [delegate saveAsFile:self.list];
//    [self saveAsFileAction:nil];
    MFMailComposeViewController* mail = [[MFMailComposeViewController alloc] init];
    [mail setSubject:@"Emails collected"];
    mail.mailComposeDelegate = self;
    NSData* csvData = [NSData dataWithContentsOfFile:[delegate dataFilePath]];
    [mail addAttachmentData:csvData mimeType:@"text/csv" fileName:@"Emails.csv"];
    [self presentViewController:mail animated:true completion:nil];
}

#pragma mark - UIAlertView Delegate

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual: @"selectorSegue"]) {
        SelectorViewController* selecVC = segue.destinationViewController;
        selecVC.delegate = self;
    }
}

#pragma mark - Selector Delegate

-(void)didSelect {
    AppDelegate* delegate = [UIApplication sharedApplication].delegate;
    self.list = [NSMutableArray arrayWithArray:[delegate getLocalArray]];
    [self.tableView reloadData];
    [self addNavigationItems];
}

#pragma mark - UITableView Datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    id emailObject = self.list[indexPath.row];
//    cell.textLabel.text = emailObject;
    cell.emailLabel.text = emailObject;
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
    return cell;
}

#pragma mark - MFMailComposeController Delegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end