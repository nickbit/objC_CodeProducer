//
//  NBOutletData.h
//  CodeProducer
//
//  Created by Nikos Bitoulas on 8/7/17.
//  Copyright © 2017 Nikos Bitoulas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBOutletData : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *className;

+(instancetype)dataWithName:(NSString *)name className:(NSString *)className;

@end
