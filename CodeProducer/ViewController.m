//
//  ViewController.m
//  CodeProducer
//
//  Created by Nikos Bitoulas on 8/7/17.
//  Copyright © 2017 Nikos Bitoulas. All rights reserved.
//

#import "ViewController.h"
#import "NBCodeProducer.h"
#import "NBOutletData.h"

@interface ViewController()

@property(nonatomic, strong) NBCodeProducer *codeProducer;

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    _codeProducer = [NBCodeProducer new];
    [self produceCodeAction:nil];
}

-(IBAction)produceCodeAction:(id)sender {
    NSArray *outlets = [self outlets];
    NSString *className = [self className];
    NSString *categoryName = [self categoryName];
    [_codeProducer produceCodeWithOutlets:outlets className:className categoryName:categoryName];
}

-(NSArray *)outlets {
    return @[

             [NBOutletData dataWithName:@"fieldName" className:@"UILabel"],
             [NBOutletData dataWithName:@"textField" className:@"UITextField"],
             [NBOutletData dataWithName:@"helpTextContainer" className:@"UIView"],
             [NBOutletData dataWithName:@"helpTextLabel" className:@"UILabel"],
             [NBOutletData dataWithName:@"noticeLabel" className:@"UILabel"],
             [NBOutletData dataWithName:@"paymentContainer" className:@"UIView"],
             [NBOutletData dataWithName:@"getAmountTitleLabel" className:@"UILabel"],
             [NBOutletData dataWithName:@"getAmountLabel" className:@"UILabel"],
//             [NBOutletData dataWithName:@"feeAmountTitleLabel" className:@"UILabel"],
//             [NBOutletData dataWithName:@"feeAmountLabel" className:@"UILabel"],
//             [NBOutletData dataWithName:@"chargeAmountTitleLabel" className:@"UILabel"],
//             [NBOutletData dataWithName:@"chargeAmountLabel" className:@"UILabel"],
             
//             [NBOutletData dataWithName:@"outletLabel" className:@"UILabel"],
//             [NBOutletData dataWithName:@"dateLabel" className:@"UILabel"],
             [NBOutletData dataWithName:@"otherButton" className:@"UIButton"],
//             [NBOutletData dataWithName:@"firstNameFieldRow" className:@"EditFieldRow"],
//             [NBOutletData dataWithName:@"middleNameFieldRow" className:@"EditFieldRow"],
//             [NBOutletData dataWithName:@"lastNameFieldRow" className:@"EditFieldRow"],
             ];
}

-(NSString *)className {
    return @"RequiredFieldsHeaderVC";
}

-(NSString *)categoryName {
    return @"Payout";
}

-(NSString *)capitalizedString:(NSString *)string {
    return [string capitalizedString];
}

@end
