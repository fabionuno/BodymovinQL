#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Cocoa/Cocoa.h>

#import "BodymovinPreview.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);



OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    @autoreleasepool {
        NSURL *fileURL = (__bridge NSURL *)url;
        if (![[fileURL pathExtension] isEqualToString:@"json"])
        {
            return noErr;
        }
        
        NSLog(@"NUNO path %@", [[fileURL absoluteString] stringByDeletingLastPathComponent]);
        
        //load JSON file
        NSError *loaderError;
        NSString *jsonFile = [[NSString alloc] initWithContentsOfURL:fileURL
                                                            encoding:NSUTF8StringEncoding
                                                               error:&loaderError];

        if (QLPreviewRequestIsCancelled(preview))
            return noErr;
        
        if (jsonFile && !loaderError)
        {
            BodymovinPreview *prev = [[BodymovinPreview alloc] initWithAnimation:jsonFile usingURL:fileURL];
            
            if (!QLPreviewRequestIsCancelled(preview) && [prev isAnimation]) {
                
                NSString *html = [prev generateHTML];
                NSDictionary *props = [prev previewProperties];
                
                NSData *data = [html dataUsingEncoding: NSUTF8StringEncoding];
                CFDataRef previewData = (__bridge CFDataRef)data;
                CFDictionaryRef properties = (__bridge CFDictionaryRef)props;
                QLPreviewRequestSetDataRepresentation(preview, previewData, kUTTypeHTML, properties);
            }
        }
    }
    
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
