//
//  GZViewController.m
//  HuntingZombiesTool
//
//  Created by 葛高召 on 12/20/2023.
//  Copyright (c) 2023 葛高召. All rights reserved.
//

#import "GZViewController.h"

@interface GZViewController ()

@end

@implementation GZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIButton *tmpBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 50)];
    [tmpBtn addTarget:self action:@selector(tmpBtnClickd:) forControlEvents:UIControlEventTouchUpInside];
    tmpBtn.backgroundColor = [UIColor redColor];
    [tmpBtn setTitle:@"Button" forState:UIControlStateNormal];
    [self.view addSubview:tmpBtn];
}

#pragma mark -------------------------- Response  Event

- (void)tmpBtnClickd:(UIButton *)sender {
    UIView* testObj = [[UIView alloc] init];
    [testObj release];
    [testObj setNeedsLayout];
}

@end
