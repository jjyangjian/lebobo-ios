//
//  SWMD5DataSigner.m
//  SafepayService
//
//  Created by wenbi on 11-4-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SWMD5DataSigner.h"


@implementation SWMD5DataSigner

- (NSString *)algorithmName {
	return @"MD5";
}

- (NSString *)signString:(NSString *)string {
	return @"";
}

@end
