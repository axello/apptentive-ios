//
//  ATPerson.h
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 10/2/12.
//  Copyright (c) 2012 Apptentive, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ATCurrentPersonPreferenceKey;

@interface ATPersonInfo : NSObject <NSCoding>@property (nonatomic, copy) NSString *apptentiveID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *facebookID;
@property (nonatomic, copy) NSString *emailAddress;
@property (nonatomic, copy) NSString *secret;
@property (nonatomic, assign) BOOL needsUpdate;
@property (nonatomic, readonly) BOOL hasEmailAddress;
@property (nonatomic, readonly) NSDictionary *apiJSON;

+ (ATPersonInfo *)currentPerson;

/*! If json is nil will not create a new person and will return nil. */
+ (ATPersonInfo *)newPersonFromJSON:(NSDictionary *)json;

- (void)saveAsCurrentPerson;

@end
