//
//  ApptentivePerson.m
//  ApptentiveConnect
//
//  Created by Frank Schmitt on 11/15/16.
//  Copyright © 2016 Apptentive, Inc. All rights reserved.
//

#import "ApptentivePerson.h"
#import "ApptentiveMutablePerson.h"

static NSString * const NameKey = @"name";
static NSString * const EmailAddressKey = @"emailAddress";

@implementation ApptentivePerson

//- (instancetype)initWithName:(NSString *)name emailAddress:(NSString *)emailAddress customData:(NSDictionary<NSString *,NSObject<NSCoding> *> *)customData {
//	self = [super init];
//
//	if (self) {
//		_name = name;
//		_emailAddress = emailAddress;
//	}
//
//	return self;
//}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	if (self) {
		_name = [aDecoder decodeObjectOfClass:[NSString class] forKey:NameKey];
		_emailAddress = [aDecoder decodeObjectOfClass:[NSString class] forKey:EmailAddressKey];
	}

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];

	[aCoder encodeObject:self.name forKey:NameKey];
	[aCoder encodeObject:self.emailAddress forKey:EmailAddressKey];
}

- (instancetype)initAndMigrate {
	NSString *name;
	NSString *emailAddress;
	NSDictionary *customData;
	NSString *identifier;

	NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:@"ATPersonLastUpdateValuePreferenceKey"];

	if (data) {
		NSDictionary *person = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		if ([person isKindOfClass:[NSDictionary class]]) {
			name = person[@"name"];
			emailAddress = person[@"email"];
			customData = person[@"custom_data"];
		}
	}

	self = [super initWithCustomData:customData identifier:identifier];

	if (self) {
		_name = name;
		_emailAddress = emailAddress;
	}

	return self;
}

- (instancetype)initWithMutablePerson:(ApptentiveMutablePerson *)mutablePerson {
	self = [super initWithCustomData:mutablePerson.customData identifier:mutablePerson.identifier];

	if (self) {
		_name = mutablePerson.name;
		_emailAddress = mutablePerson.emailAddress;
	}

	return self;
}

@end

@implementation ApptentivePerson (JSON)

+ (NSDictionary *)JSONKeyPathMapping {
	return @{
			 @"custom_data": NSStringFromSelector(@selector(customData)),
			 @"email": NSStringFromSelector(@selector(emailAddress)),
			 @"name": NSStringFromSelector(@selector(name))
			 };
}

@end
