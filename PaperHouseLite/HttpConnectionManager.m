//
//  HttpConnectionManager.m
//  Painter
//
//  Created by 1901 on 11-1-17.
//  Email: kaixuan1901@gmail.com
//  Copyright 2011 Unic. All rights reserved.
//

#import "HttpConnectionManager.h"

#define	KNetworkTimeoutInterval		45

#pragma mark RequestResultInfo_H
@interface RequestResultInfo : NSObject 
{
	id				delegate;
	SEL				resultHandler;
	SEL				faultHandler;
	NSMutableData*	resultData;
}

@property (retain)id	delegate;
@property SEL	resultHandler;
@property SEL	faultHandler;
@property (retain,nonatomic)NSMutableData* resultData;

@end

#pragma mark RequestResultInfo_M
@implementation RequestResultInfo

@synthesize delegate, resultHandler, faultHandler, resultData;

@end



#pragma mark HttpConnectionManager_M
@implementation HttpConnectionManager

@synthesize requests;

- init 
{
    if ((self = [super init])) {		
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		self.requests = dict;
		[dict release];	
    }
	
    return self;
}

- (void)dealloc 
{
	[requests release];
    [super dealloc];
}


/*!
 @method 异步提交GET请求 
 @param  url:			请求地址
 @param  delegate:		回调处理的类
 @param  resultHandler:	请求成功回调处理函数
 @param  faultHandler:	请求失败回调处理函数
 @result void
 */
- (void)async_doGet:(NSString*)url 
		   delegate:(id)delegate
	  resultHandler:(SEL)resultHandler 
	   faultHandler:(SEL)faultHandler
{		
	NSMutableURLRequest* request = [HttpConnectionManager allocURLRequestForGET:url];
	
	
	NSURLConnection *connection = [[NSURLConnection alloc]
								   initWithRequest:request
								   delegate:self];
	
	NSMutableData *aData = [[NSMutableData alloc] init];
	RequestResultInfo* rrInfo = [RequestResultInfo new];
	rrInfo.delegate = delegate;
	rrInfo.resultHandler = resultHandler;
	rrInfo.faultHandler = faultHandler;
	rrInfo.resultData = aData;
	[aData release];
	
	[requests setObject:rrInfo forKey: [NSValue valueWithNonretainedObject:connection]];
	[rrInfo release];
	
	[connection release];
	[request release];
}


/*!
 @method 异步提交POST请求 
 @param url:			请求地址
 @param delegate:		回调处理的类
 @param resultHandler:	请求成功回调处理函数
 @param faultHandler:	请求失败回调处理函数
 @result void
 */
- (void)async_doPost:(NSString*)url	
			postData:(NSString*)content
			delegate:(id)delegate 
	   resultHandler:(SEL)resultHandler
		faultHandler:(SEL)faultHandler
{	
	NSMutableURLRequest* request = [HttpConnectionManager allocURLRequestForPOST:url postData:content];

	
	NSURLConnection *connection = [[NSURLConnection alloc]
								   initWithRequest:request
								   delegate:self];
	
	
	NSMutableData *aData = [[NSMutableData alloc] init];
	RequestResultInfo* rrInfo = [RequestResultInfo new];
	rrInfo.delegate = delegate;
	rrInfo.resultHandler = resultHandler;
	rrInfo.faultHandler = faultHandler;
	rrInfo.resultData = aData;
	[aData release];
	
	[requests setObject:rrInfo forKey: [NSValue valueWithNonretainedObject:connection]];
	[rrInfo release];
	
	[connection release];
	[request release];
}


#pragma mark NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	RequestResultInfo* rrInfo = [requests objectForKey: [NSValue valueWithNonretainedObject:connection]];
	[rrInfo.resultData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
	RequestResultInfo* rrInfo = [requests objectForKey: [NSValue valueWithNonretainedObject:connection]];
	[rrInfo.resultData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	RequestResultInfo* rrInfo = [requests objectForKey: [NSValue valueWithNonretainedObject:connection]];
	
	if ([rrInfo.delegate respondsToSelector:rrInfo.resultHandler])
		[rrInfo.delegate performSelector:rrInfo.resultHandler withObject:rrInfo.resultData];
	
	[requests removeObjectForKey:[NSValue valueWithNonretainedObject:connection]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	RequestResultInfo* rrInfo = [requests objectForKey: [NSValue valueWithNonretainedObject:connection]];
	
	if ([rrInfo.delegate respondsToSelector:rrInfo.faultHandler])
		[rrInfo.delegate performSelector:rrInfo.faultHandler withObject:error];
	
	[requests removeObjectForKey:[NSValue valueWithNonretainedObject:connection]];
}


/*!
 @method GET方式HTTP请求
 @param	url: http请求的URL地址
 @result 服务器返回的结果
 */
+ (NSData*)sync_doGet:(NSString*)url
{	
	NSMutableURLRequest* request	= [HttpConnectionManager allocURLRequestForGET:url];
	NSHTTPURLResponse* response		= NULL;
	NSError*	error				= NULL;
	NSData*		receivedData		= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[request release];
	
	if ([response statusCode] != 200) {
		return nil;
	}
	
	return receivedData;
}


/*!
@method POST方式HTTP请求
@param url:		http请求的URL地址
@param content:	提交到服务器的内容
@result 服务器返回的结果
*/
+ (NSData*)sync_doPost:(NSString*)url data:(NSString*)content
{	
	NSMutableURLRequest* request	= [HttpConnectionManager allocURLRequestForPOST:url postData:content];
	NSHTTPURLResponse*	response	= NULL;
	NSError*	error				= NULL;
	NSData*		receivedData			= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[request release];


	if ([response statusCode] != 200) {
		return nil;
	}
	
	return receivedData;
}


#pragma mark staticMethod
+ (NSMutableURLRequest*)allocURLRequestForGET:(NSString*)url
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setTimeoutInterval:KNetworkTimeoutInterval];
	[request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
	[request setURL:[NSURL URLWithString:url]];	
	[request setHTTPMethod:@"GET"];
	
	return request;
}


+ (NSMutableURLRequest*)allocURLRequestForPOST:(NSString *)url postData:(NSString*)content
{
	NSData* httpContent = [content dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setTimeoutInterval:KNetworkTimeoutInterval];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
	[request setURL:[NSURL URLWithString:url]];	
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:httpContent];
	
	return request;
}


@end