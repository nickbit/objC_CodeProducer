//
//  NBCodeProducer.h
//  CodeProducer
//
//  Created by Nikos Bitoulas on 8/7/17.
//  Copyright © 2017 Nikos Bitoulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NBOutletData;

@interface NBCodeProducer : NSObject

-(void)produceCodeWithOutlets:(NSArray<NBOutletData *> *)outlets className:(NSString *)className categoryName:(NSString *)categoryName;

@end
