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
    NSURL* _fileURL;
    NSMutableArray* _assets;
}

- (BOOL)isAnimation;
- (instancetype) initWithAnimation: (NSString *)json usingURL:(NSURL *)URL;
- (NSString *) generateHTML;
- (NSDictionary *)previewProperties;


@end
