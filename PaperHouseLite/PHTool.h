//
//  PHTool.h
//  PaperHouseLite
//
//  Created by cod7ce on 10/31/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PowerMenuItemView.h"
#import "PHDocmentImage.h"

typedef enum {
    sina,
    renren,
    tencent,
    douban,
    kaixin,
    net163
}ShareType;

@interface PHTool : NSObject

+(void)getConfigWithURL:(NSURL *)url XMLDeletgate:(PowerMenuItemView *)xmlDelegate;

+(NSMutableArray *)parseToDocumentImageWithDesc:(NSString *)desc;

+(BOOL)checkPicturePath;

+(void)addAppAsLoginItem;
+(void)deleteAppFromLoginItem;
+(void)downloadWPWithPath:(NSString *)path AndWeatherSwif:(bool)swif;
+ (NSDictionary *)getDataWithURL:(NSString *)url;
+(void)shareImageWithDocumentImage:(PHDocmentImage *)docImage Type:(ShareType)type;

+(NSString *)getURLStringWithString:(NSString *)os;
+(NSString *) getFileNameURLWithDocumentImage:(PHDocmentImage *)documentImage;

+(void)setWallpaperWithPath:(NSString *)path AndName:(NSString *)name;
@end
