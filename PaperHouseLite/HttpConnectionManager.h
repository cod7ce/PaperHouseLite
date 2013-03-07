//
//  HttpConnectionManager.h
//  Painter
//
//  Created by 1901 on 11-1-17.
//  Email: kaixuan1901@gmail.com
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface HttpConnectionManager : NSObject 
{
	NSMutableDictionary *requests;
}

@property (nonatomic,retain) NSMutableDictionary *requests;

/*! 异步GET */
- (void)async_doGet:(NSString*)url delegate:(id)delegate 
									resultHandler:(SEL)resultHandler
									faultHandler:(SEL)faultHandler;

/*! 异步POST */
- (void)async_doPost:(NSString*)url	postData:(NSString*)content
									delegate:(id)delegate 
									resultHandler:(SEL)resultHandler
									faultHandler:(SEL)faultHandler;


/*! 同步GET */
+ (NSData*)sync_doGet:(NSString*)url;

/*! 同步POST */
+ (NSData*)sync_doPost:(NSString*)url data:(NSString*)content;

/*! 获取get方式的URLRequest 使用完后需release获取到的对象 */
+ (NSMutableURLRequest*)allocURLRequestForGET:(NSString*)url;

/*! 获取post方式的URLRequest 使用完后需release获取到的对象 */
+ (NSMutableURLRequest*)allocURLRequestForPOST:(NSString *)url postData:(NSString*)content;
@end
