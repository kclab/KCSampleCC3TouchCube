//
//  KCSampleCC3TouchCubeAppDelegate.h
//  KCSampleCC3TouchCube
//
//  Created by  on 11/12/24.
//  Copyright KCLAB 2011年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCNodeController.h"
#import "CC3World.h"

@interface KCSampleCC3TouchCubeAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow* window;
	CCNodeController* viewController;
}

@property (nonatomic, retain) UIWindow* window;

@end
