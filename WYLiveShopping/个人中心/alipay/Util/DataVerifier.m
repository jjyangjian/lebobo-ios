//
//  DataVerifier.m
//  AlixPayDemo
//
//  Created by Jing Wen on 8/2/11.
//  Copyright 2011 alipay.com. All rights reserved.
//

#import "DataVerifier.h"


#import "SWRSADataVerifier.h"

id<DataVerifier> CreateRSADataVerifier(NSString *publicKey) {
	
	return [[SWRSADataVerifier alloc] initWithPublicKey:publicKey];
	
}