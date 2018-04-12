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
             [NBOutletData dataWithName:@"shadowContainer" className:@"UIView"],
             [NBOutletData dataWithName:@"convertingFromLabel" className:@"UILabel"],
             
             [NBOutletData dataWithName:@"sourceCurrencyContainer" className:@"UIView"],
             [NBOutletData dataWithName:@"sourceCurrencyLabel" className:@"UILabel"],
             [NBOutletData dataWithName:@"sourceCurrencyChangeImageView" className:@"UIImageView"],
             [NBOutletData dataWithName:@"sourceAmountTextField" className:@"UITextField"],
             [NBOutletData dataWithName:@"walletBalanceLabel" className:@"UILabel"],
             
             [NBOutletData dataWithName:@"convertImageView" className:@"UIImageView"],
             [NBOutletData dataWithName:@"horizontalLine" className:@"UIView"],
             
             [NBOutletData dataWithName:@"convertingToLabel" className:@"UILabel"],
             
             [NBOutletData dataWithName:@"targetCurrencyContainer" className:@"UIView"],
             [NBOutletData dataWithName:@"targetCurrencyLabel" className:@"UILabel"],
             [NBOutletData dataWithName:@"targetCurrencyChangeImageView" className:@"UIImageView"],
             [NBOutletData dataWithName:@"targetAmountTextField" className:@"UITextField"],
             
             [NBOutletData dataWithName:@"rateTitleLabel" className:@"UILabel"],
             [NBOutletData dataWithName:@"rateLabel" className:@"UILabel"],

             [NBOutletData dataWithName:@"convertSlider" className:@"COSlider"],
             [NBOutletData dataWithName:@"messageLabel" className:@"UILabel"],
             ];
}

-(NSString *)className {
    return @"COConvertFundsVC";
}

-(NSString *)categoryName {
    return @"ConvertFunds";
}

-(NSString *)capitalizedString:(NSString *)string {
    return [string capitalizedString];
}

@end
