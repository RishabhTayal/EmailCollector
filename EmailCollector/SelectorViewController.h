//
//  SelectorViewController.h
//  EmailCollector
//
//  Created by Rishabh Tayal on 8/12/15.
//  Copyright (c) 2015 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectorDelegate;

@interface SelectorViewController : UIViewController

@property (nonatomic, weak) id<SelectorDelegate> delegate;

@end

@protocol SelectorDelegate <NSObject>

-(void)didSelect;

@end