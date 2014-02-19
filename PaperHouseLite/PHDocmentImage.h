//
//  PHDocmentImage.h
//  PaperHouseLite
//
//  Created by cod7ce on 11/1/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHDocmentImage : NSObject

@property (nonatomic,retain) NSString *author;
@property (nonatomic,retain) NSString *copyright;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *url;

- (id)initWithAuthor:(NSString *)author Copyright:(NSString *)copyright Name:(NSString *)name URL:(NSString *)url;

- (void)setProperties:(NSDictionary *)properties;

@end
