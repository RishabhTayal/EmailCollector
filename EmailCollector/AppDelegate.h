//
//  AppDelegate.h
//  EmailCollector
//
//  Created by Rishabh Tayal on 8/12/15.
//  Copyright (c) 2015 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(NSArray*)getLocalArray;
-(void)saveAsFile:(NSArray*)array;
-(NSString *)dataFilePath;

@end

