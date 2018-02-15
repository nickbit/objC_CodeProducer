//
//  NBOutletData.m
//  CodeProducer
//
//  Created by Nikos Bitoulas on 8/7/17.
//  Copyright © 2017 Nikos Bitoulas. All rights reserved.
//

#import "NBOutletData.h"

@implementation NBOutletData

-(instancetype)initWithName:(NSString *)name className:(NSString *)className {
    self = [super init];
    if (self) {
        _name = name;
        _className = className;
    }
    return self;
}

+(instancetype)dataWithName:(NSString *)name className:(NSString *)className {
    return [[self alloc] initWithName:name className:className];
}

@end
