//
//  CYDispacchLIFOQueue.m
//  CYLIFODispacthQueue
//
//  Created by liujizhou on 17/6/15.
//  Copyright © 2017年 liujizhou. All rights reserved.
//

#import "CYDispatchLIFOQueue.h"

@implementation CYDispatchLIFOQueue
{
    NSMutableArray*   _taskWaitArray;
    dispatch_queue_t  _innerQueue;
    dispatch_queue_t  _taskRunQueue;
    NSInteger         _taskRunCount;
    NSInteger         _maxOperationCount;
}


- (instancetype)initWithQueueName:(NSString*)queueName maxOperationCount:(NSInteger)maxOperationCount
{
    if (self = [super init]) {
        if (maxOperationCount > 1) {
            _taskRunQueue   = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
        }else
        {
            _taskRunQueue   = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
        }
        _maxOperationCount = maxOperationCount > 0 ? maxOperationCount : 1;
        _innerQueue   = dispatch_queue_create("CYLIFOInnerQueue", DISPATCH_QUEUE_SERIAL);
        _taskWaitArray = [NSMutableArray arrayWithCapacity:10];
        _taskRunCount = 0;
    }
    return self;
}

- (void)performTaskBlock:(dispatch_block_t _Nonnull)taskBlock waitUntilDone:(BOOL)waitUntilDone LIFO:(BOOL)LIFO
{
    dispatch_semaphore_t sema = nil;
    if (waitUntilDone) {
        sema = dispatch_semaphore_create(0);
    }
    dispatch_block_t innerBlock = ^{
        if (taskBlock) {
            taskBlock();
        }
        if (sema) {
            dispatch_semaphore_signal(sema);
        }
    };
    
    dispatch_async(_innerQueue, ^{
        if(_taskRunCount < _maxOperationCount){
            [self runTaskBlock:innerBlock];
        }else{
            if (LIFO) { // 如果需要后进先出 则加到最前面
                [_taskWaitArray insertObject:innerBlock atIndex:0];
            }else
            {
                [_taskWaitArray addObject:innerBlock];
            }
        }
    });
    
    if (waitUntilDone && sema) {
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
}

-(void)runTaskBlock:(dispatch_block_t)innerBlock
{
    _taskRunCount++;
    NSLog(@"runTaskBlock");
    dispatch_async(_taskRunQueue, ^{
        if (innerBlock) {
            innerBlock();
        }
        NSLog(@"run end TaskBlock");
        dispatch_async(_innerQueue, ^{
            _taskRunCount--;
            [self startNextTask];
        });
        
    });
}


-(void)startNextTask
{
    if ([_taskWaitArray count] > 0){
        dispatch_block_t innerBlock = [_taskWaitArray firstObject];// 优先解析先添加的
        [self runTaskBlock:innerBlock];
        [_taskWaitArray removeObjectAtIndex:0];
    }
}
@end
