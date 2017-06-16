//
//  CYDispacchLIFOQueue.h
//  CYLIFODispacthQueue
//
//  Created by liujizhou on 17/6/15.
//  Copyright © 2017年 liujizhou. All rights reserved.
///

#import <Foundation/Foundation.h>




@interface CYDispatchLIFOQueue : NSObject

- (instancetype _Nonnull)initWithQueueName:(NSString* _Nonnull )queueName maxOperationCount:(NSInteger)maxOperationCount;

- (void)performTaskBlock:(dispatch_block_t _Nonnull)taskBlock waitUntilDone:(BOOL)waitUntilDone LIFO:(BOOL)LIFO;

@end

