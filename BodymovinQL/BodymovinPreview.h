//
//  BodymovinPreview.h
//  BodymovinQL
//
//  Created by Fabio Nuno on 28/02/17.
//
#include <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>

@interface BodymovinPreview : NSObject {
    
    NSString* _animation;
}

+ (BOOL)isValidJson:(NSString *)json;
- (instancetype) initWithAnimation: (NSString *)json;
- (NSString *) generateHTML;
- (NSDictionary *)previewProperties;


@end
