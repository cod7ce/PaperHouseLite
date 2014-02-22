//
//  PHDocmentImage.m
//  PaperHouseLite
//
//  Created by cod7ce on 11/1/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import "PHDocmentImage.h"

@implementation PHDocmentImage

- (id)init
{
    self = [super init];
    if (self) {
        
    } 
    return self;
}

- (id)initWithAuthor:(NSString *)author Copyright:(NSString *)copyright Name:(NSString *)name URL:(NSString *)url Thumbnail:(NSString *)thumbnail
{
    self = [super init];
    if (self) {
        self.author = author;
        self.name = name;
        self.url = url;
        self.copyright = copyright;
        self.thumbnailUrl = thumbnail;
    }
    return self;
}

- (void)setProperties:(NSDictionary *)properties
{
    self.author = [properties objectForKey:@"author"];
    self.name = [properties objectForKey:@"name"];
    self.url = [properties objectForKey:@"url"];
    self.thumbnailUrl = [properties objectForKey:@"thumbnail_url"];
    self.copyright = [properties objectForKey:@"copyright_link"];
}

@end
