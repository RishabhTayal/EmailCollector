//
//  ViewController.m
//  EmailCollector
//
//  Created by Rishabh Tayal on 8/12/15.
//  Copyright (c) 2015 Rishabh Tayal. All rights reserved.
//

#import "ViewController.h"
#import <MessageUI/MessageUI.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSMutableArray* list;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.list = [NSMutableArray new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://api.emailhunter.co/v1/search?domain=illinois.edu&api_key=80af57421ced39fbe8de5ae7e2605565e598f484"]];
        if (data) {
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //            NSLog(@"%@", result);
            self.list = [NSMutableArray arrayWithArray:result[@"emails"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = [NSString stringWithFormat:@"%lu (Total: %@)", (unsigned long)self.list.count, (NSNumber*)result[@"results"]];
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareClicked:)];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)shareClicked:(id)sender {
    [self saveAsFileAction:nil];
    MFMailComposeViewController* mail = [[MFMailComposeViewController alloc] init];
    [mail setSubject:@"Emails collected"];
    mail.mailComposeDelegate = self;
    NSData* csvData = [NSData dataWithContentsOfFile:[self dataFilePath]];
    [mail addAttachmentData:csvData mimeType:@"text/csv" fileName:@"Emails.csv"];
    [self presentViewController:mail animated:true completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    id emailObject = self.list[indexPath.row];
    cell.textLabel.text = emailObject[@"value"];
    return cell;
}

#pragma mark - MFMailComposeController Delegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark -

- (IBAction)saveAsFileAction:(id)sender {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
        [[NSFileManager defaultManager] createFileAtPath: [self dataFilePath] contents:nil attributes:nil];
        NSLog(@"Route creato");
    }
    
    NSMutableString *writeString = [NSMutableString stringWithCapacity:0]; //don't worry about the capacity, it will expand as necessary
    
    for (int i=0; i<[self.list count]; i++) {
        [writeString appendString:[NSString stringWithFormat:@"%@, \n",[self.list objectAtIndex:i][@"value"]]];
    }
    
    //Moved this stuff out of the loop so that you write the complete string once and only once.
    NSLog(@"writeString :%@",writeString);
    
    NSFileHandle *handle;
    handle = [NSFileHandle fileHandleForWritingAtPath: [self dataFilePath] ];
    //say to handle where's the file fo write
    [handle truncateFileAtOffset:[handle seekToEndOfFile]];
    //position handle cursor to the end of file
    [handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
}

-(NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"myfile.csv"];
}

@end
