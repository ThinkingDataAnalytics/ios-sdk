//
//  HMCThreadSafeMutableDictionary.h
//  HMCThreadSafeMutableDictionary
//
//  Created by chuonghuynh on 8/9/17.
//  Copyright © 2017 Chương M. Huỳnh. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 HMCThreadSafeMutableDictionary
 */
@interface HMCThreadSafeMutableDictionary : NSObject

// For supscript
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

/**
 Convert to NSDictionray

 @return NSDictionary contains all <key,value>
 */
- (NSDictionary *)toNSDictionary;

/**
 Remove object for key

 @param key - representing object
 */
- (void)removeObjectForkey:(NSString *)key;

/**
 Remove all object in dictionary
 */
- (void)removeAllObjects;

@end
