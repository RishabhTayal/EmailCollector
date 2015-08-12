//
//  SelectorViewController.m
//  EmailCollector
//
//  Created by Rishabh Tayal on 8/12/15.
//  Copyright (c) 2015 Rishabh Tayal. All rights reserved.
//

#import "SelectorViewController.h"
#import "AppDelegate.h"

@interface SelectorViewController ()<UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel* totalLabel;
@property (nonatomic, weak) IBOutlet UILabel* minLabel;

@property (nonatomic, weak) IBOutlet UILabel* selectedLabel;
@property (nonatomic, weak) IBOutlet UISlider* slider;

@end

@implementation SelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    _totalLabel.text = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"total"]];
    _slider.maximumValue = _totalLabel.text.floatValue;
    _slider.minimumValue = [appDelegate getLocalArray].count;
    _minLabel.text = [NSString stringWithFormat:@"%d", (int)_slider.minimumValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sliderChanged:(id)sender {
    int value = (int)self.slider.value;
    int stepSize = 100;
    value = (value - value % stepSize);
    
    self.slider.value = value;
    _selectedLabel.text = [NSString stringWithFormat:@"%d", (int)_slider.value];
}

-(IBAction)doneCliced:(id)sender {
    int currentOffset = _slider.minimumValue / 100;
    int newOffset = _slider.value / 100;
    [[[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat:@"This will make %d API calls", newOffset - currentOffset] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        int currentOffset = _slider.minimumValue / 100;
        int newOffset = _slider.value / 100;
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        NSMutableArray* list = [NSMutableArray arrayWithArray:[appDelegate getLocalArray]];
        for (int i = currentOffset; i <= newOffset; i++) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.emailhunter.co/v1/search?domain=illinois.edu&offset=%d&api_key=80af57421ced39fbe8de5ae7e2605565e598f484", i]]];
                if (data) {
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    [list addObjectsFromArray:[result[@"emails"] valueForKey:@"value"]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (i == newOffset) {
                            [appDelegate saveAsFile:list];
                            [self.navigationController popViewControllerAnimated:true];
                            if (self.delegate) {
                                [self.delegate didSelect];
                            }
                        }
                    });
                }
            });
        }
    } else {
        [self.navigationController popViewControllerAnimated:true];
    }
}

@end
