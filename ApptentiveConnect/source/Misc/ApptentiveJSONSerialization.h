//
//  ApptentiveJSONSerialization.h
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 6/22/13.
//  Copyright (c) 2013 Apptentive, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ApptentiveJSONSerialization : NSObject
+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;
+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;
+ (id)JSONObjectWithData:(NSData *)data error:(NSError **)error;
+ (id)JSONObjectWithString:(NSString *)string error:(NSError **)error;
@end