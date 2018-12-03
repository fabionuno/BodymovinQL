//
//  BodymovinPreview.m
//  BodymovinQL
//
//  Created by Fabio Nuno on 28/02/17.
//

#include "BodymovinPreview.h"

@interface BodymovinPreview ()

-(NSString*) mimeTypeForFileAtPath:(NSString *) path;

@end


@implementation BodymovinPreview

- (instancetype)initWithAnimation:(NSString *)json usingURL:(NSURL *)URL {
    if ((self = [super init])) {

        _animation = json;
        _fileURL = [URL URLByDeletingLastPathComponent];

        return self;
    }
    
    return nil;
}


-(BOOL)isAnimation {

    NSError* errorInfo;
    NSData *data = [_animation dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *parsedJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorInfo];
   
    if (errorInfo != nil)
        return FALSE;
    
    NSString *width = [parsedJSON objectForKey:@"w"];
    NSString *height = [parsedJSON objectForKey:@"h"];
    
    //if is a bodymovin json, get assets file
    NSMutableArray *assetsArray = [parsedJSON mutableArrayValueForKey:@"assets"];

    if (assetsArray)
    {
        _assets = [[NSMutableArray alloc] init];
        for (NSDictionary *item in assetsArray)
        {
            if (![item objectForKey:@"layers"])
            {
                NSString *path = [item objectForKey:@"u"];
                [_assets addObject:[path stringByAppendingString:[item objectForKey:@"p"]]];
            }
        }
    }
    
    return (width != nil && height!=nil);
}


-(NSString *)generateHTML {
    return [NSString stringWithFormat:@"<!DOCTYPE html> <meta charset=\"UTF-8\"> <head> <style>:focus{outline:0}body,html{background-color:#fff;margin:0;height:100%%;overflow:hidden}#bodymovin{background-color:#fff;width:100%%;height:90%%;display:block;overflow:hidden;transform:translate3d(0,0,0);text-align:center;margin:auto;opacity:1}button{border:none;background:0 0;outline-style:none}select{text-align:center;text-align-last:center}option{text-align:left}#controls{display:flex;justify-content:space-around;align-items:stretch}#controls button{padding:0;display:flex}#controls .left{flex:0 0;display:flex;justify-content:center}#controls .seeker{flex:1;display:flex}#controls #seek-bar{width:100%%}#controls .right{flex:0 0 160px;display:flex;align-items:center;margin:0 8px;justify-content:space-between}.button-selector{background-color:#000;color:#fff;font-size:inherit;padding:.4em;font-size:x-small;border:0;margin:0;border-radius:3px;text-indent:.01px;text-overflow:'';-webkit-appearance:button}#speed-selector{width:40px}</style> <script src=\"cid:bodymovin.min.js\"></script> </head> <body> <div id=\"bodymovin\"></div> <div id=\"controls\"> <div class=\"left\"> <button type=\"button\" id=\"play-pause\"> <svg id=\"play-icon\" display=\"none\" fill=\"#000000\" height=\"24\" viewBox=\"0 0 24 24\" width=\"24\" xmlns=\"http://www.w3.org/2000/svg\"> <path d=\"M8 5v14l11-7z\"/> <path d=\"M0 0h24v24H0z\" fill=\"none\"/> </svg> <svg id=\"pause-icon\" fill=\"#000000\" height=\"24\" viewBox=\"0 0 24 24\" width=\"24\" xmlns=\"http://www.w3.org/2000/svg\"> <path d=\"M6 19h4V5H6v14zm8-14v14h4V5h-4z\"/> <path d=\"M0 0h24v24H0z\" fill=\"none\"/> </svg> </button> </div> <div class=\"seeker\"> <input type=\"range\" id=\"seek-bar\" value=\"0\"> </div> <div class=\"right\"> <button type=\"button\" id=\"background\"> <svg fill=\"#000000\" height=\"26\" viewBox=\"0 0 24 24\" width=\"26\" xmlns=\"http://www.w3.org/2000/svg\"> <path d=\"M0 0h24v24H0z\" fill=\"none\"/> <path d=\"M21 3H3c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h18c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16.01H3V4.99h18v14.02zM8 16h2.5l1.5 1.5 1.5-1.5H16v-2.5l1.5-1.5-1.5-1.5V8h-2.5L12 6.5 10.5 8H8v2.5L6.5 12 8 13.5V16zm4-7c1.66 0 3 1.34 3 3s-1.34 3-3 3V9z\"/> </svg> </button> <select id=\"speed-selector\" class=\"button-selector\"> <option disabled=\"disabled\">Animation Speed</option> <option value=\"0.25\">0.25</option> <option value=\"0.75\">0.75</option> <option selected=\"selected\" value=\"1\">x1</option> <option value=\"1.25\">1.25</option> <option value=\"1.5\">1.5</option> <option value=\"2\">2</option> </select> <select id=\"engine-selector\" class=\"button-selector\"> <option disabled=\"disabled\">Render engine</option> <option selected=\"selected\" value=\"svg\">SVG</option> <option value=\"canvas\">CANVAS</option> <option value=\"html\">HTML</option> </select> </div> </div> <script> var animData=%@;var config={container: document.getElementById('bodymovin'), renderer: 'svg',loop: true,autoplay: true, animationData: animData};var player=new BasicPlayer();player.buildControls(config);</script></body>",_animation];
}

- (NSDictionary *) previewProperties {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *jsFile = [bundle URLForResource:@"bodymovin.min" withExtension:@"js"];
    NSData *jsData = [NSData dataWithContentsOfURL:jsFile];


    // Properties
    NSMutableDictionary* properties = [NSMutableDictionary dictionaryWithCapacity:3];
    [properties setObject:@"UTF-8" forKey:(__bridge NSString*)kQLPreviewPropertyTextEncodingNameKey];
    [properties setObject:@"text/html" forKey:(__bridge NSString*)kQLPreviewPropertyMIMETypeKey];
    
    NSUInteger attachmentsCount = 1;
    
    //check if animation has assets to attach in HTML
    if (_assets != nil)
        attachmentsCount += [_assets count];

    
    // Add the attachments.
    NSMutableDictionary* attachments = [NSMutableDictionary dictionaryWithCapacity:attachmentsCount];
    NSDictionary* bodymovin = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"text/javascript", (NSString *)kQLPreviewPropertyMIMETypeKey, jsData, (NSString *)kQLPreviewPropertyAttachmentDataKey, nil];
    [attachments setObject:bodymovin forKey:@"bodymovin.min.js"];

    //append animation assets
    if (attachmentsCount > 1) {
        for (NSString *assetsFile in _assets) {
            if ([assetsFile hasPrefix:@"data:"]) {
                NSRange semicolonRange = [assetsFile rangeOfString:@";"];
                NSString *type = [assetsFile substringWithRange:NSMakeRange(5, semicolonRange.location-5)];
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:assetsFile]];
                NSDictionary* attachment = [NSMutableDictionary dictionaryWithObjectsAndKeys:type, (NSString *)kQLPreviewPropertyMIMETypeKey, data, (NSString *)kQLPreviewPropertyAttachmentDataKey, nil];
                [attachments setObject:attachment forKey:assetsFile];
            } else {
                attach(_fileURL, attachments, [self mimeTypeForFileAtPath:assetsFile], assetsFile);
            }
        }
    }
    
    [properties setObject:attachments forKey:(NSString*)kQLPreviewPropertyAttachmentsKey];
    
    return properties;
}

-(NSString*) mimeTypeForFileAtPath:(NSString *) path {
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)mimeType;
}

static void attach(NSURL *attachURL, NSMutableDictionary* attachments, NSString* type, NSString* fileName)
{
    NSData *data = [NSData dataWithContentsOfURL:[attachURL URLByAppendingPathComponent:fileName]];
    NSDictionary* attachment = [NSMutableDictionary dictionaryWithObjectsAndKeys:type, (NSString *)kQLPreviewPropertyMIMETypeKey, data, (NSString *)kQLPreviewPropertyAttachmentDataKey, nil];
    [attachments setObject:attachment forKey:fileName];
}
@end
