//
//  ViewController.m
//  CYLIFODispacthQueue
//
//  Created by liujizhou on 17/6/15.
//  Copyright © 2017年 liujizhou. All rights reserved.
//

#import "ViewController.h"
#import "CYDispatchLIFOQueue.h"

@interface ViewController ()
{
    NSMutableDictionary *_waitTaskDic;
    NSMutableArray *_runTaskArray;
    dispatch_queue_t  _processQueue;
    CYDispatchLIFOQueue *_LIFOQueue;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testLIFOQueue];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)testLIFOQueue
{
    _processQueue   = dispatch_queue_create("testQueue", DISPATCH_QUEUE_SERIAL);
    _waitTaskDic = [[NSMutableDictionary alloc]initWithCapacity:10];
    _runTaskArray = [NSMutableArray arrayWithCapacity:10];
    _LIFOQueue = [[CYDispatchLIFOQueue alloc]initWithQueueName:@"testLIFOQueue" maxOperationCount:10];
    for (NSInteger i = 0; i< 60; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSInteger result = [self runTask: i];
            NSLog(@"run end req(%zd),result(%zd)",i,result);
        });
    }
    
    
}

- (NSInteger)runTask:(NSInteger)req
{
    __block NSInteger result = 0;
    
    [_LIFOQueue performTaskBlock:^{
        result = req;
        NSLog(@"run req(%zd),result(%zd)",req,result);
        } waitUntilDone: YES LIFO:YES];
    return result;
}

@end
