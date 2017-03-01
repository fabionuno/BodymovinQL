//
//  BodymovinPreview.m
//  BodymovinQL
//
//  Created by Fabio Nuno on 28/02/17.
//

#include "BodymovinPreview.h"

@implementation BodymovinPreview

- (instancetype)initWithAnimation:(NSString *)json {
    _animation = json;
    if ([BodymovinPreview isValidJson:json]) {
        self = [super init];
        return self;
    }
    
    return nil;
}


+(BOOL)isValidJson:(NSString *)json {

    NSError* errorInfo;
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *parsedJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorInfo];
   
    if (errorInfo != nil)
        return FALSE;
    
    NSString *width = [parsedJSON objectForKey:@"w"];
    NSString *height = [parsedJSON objectForKey:@"h"];
    
    return (width != nil && height!=nil);
}


-(NSString *)generateHTML {
    NSMutableString *stringBuilder = [NSMutableString string];
    
    [stringBuilder appendString:@"<!DOCTYPE html><meta charset=\"UTF-8\"><head> <style>body, html{background-color:#fff; margin: 0px; height: 100%; overflow: hidden;}#bodymovin{background-color:#fff; width:100%; height:90%; display:block; overflow: hidden; transform: translate3d(0,0,0); text-align: center; margin: auto; opacity: 1;}button{border:none; background: transparent; outline-style:none;}#controls{width:100%; overflow:hidden;}#controls .left{width:50px; float:left}#controls .seeker{margin:0 50px; height: 31px;}#controls #seek-bar{width:100%; vertical-align: -webkit-baseline-middle;}#controls .right{width:50px; float:right; text-align: right;}</style><script type='text/javascript' src='cid:bodymovin.min.js'></script></head><body>"];
    
    [stringBuilder appendString:@"<div id=\"bodymovin\"></div><div id=\"controls\"> <div class=\"left\"> <button type=\"button\" id=\"play-pause\"> <svg id=\"play-icon\" display=\"none\" fill=\"#000000\" height=\"24\" viewBox=\"0 0 24 24\" width=\"24\" xmlns=\"http://www.w3.org/2000/svg\"> <path d=\"M8 5v14l11-7z\"/> <path d=\"M0 0h24v24H0z\" fill=\"none\"/> </svg> <svg id=\"pause-icon\" fill=\"#000000\" height=\"24\" viewBox=\"0 0 24 24\" width=\"24\" xmlns=\"http://www.w3.org/2000/svg\"> <path d=\"M6 19h4V5H6v14zm8-14v14h4V5h-4z\"/> <path d=\"M0 0h24v24H0z\" fill=\"none\"/> </svg> </button> </div><div class=\"right\"> <button type=\"button\" id=\"background\"> <svg fill=\"#000000\" height=\"24\" viewBox=\"0 0 24 24\" width=\"24\" xmlns=\"http://www.w3.org/2000/svg\"> <path d=\"M0 0h24v24H0z\" fill=\"none\"/> <path d=\"M21 3H3c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h18c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16.01H3V4.99h18v14.02zM8 16h2.5l1.5 1.5 1.5-1.5H16v-2.5l1.5-1.5-1.5-1.5V8h-2.5L12 6.5 10.5 8H8v2.5L6.5 12 8 13.5V16zm4-7c1.66 0 3 1.34 3 3s-1.34 3-3 3V9z\"/> </svg> </button> </div><div class=\"seeker\"> <input type=\"range\" id=\"seek-bar\" value=\"0\"> </div></div>"];
    
    [stringBuilder appendFormat:@"<script>\nvar animData = %@;\n", _animation];
    [stringBuilder appendString:@"var config={container: document.getElementById('bodymovin'), renderer: 'svg',loop: true,autoplay: true, animationData: animData};var anim=bodymovin.loadAnimation(config);var player=new BasicPlayer();player.buildControls(anim);</script></body></html>"];
    return stringBuilder;
}

- (NSDictionary *) previewProperties {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *jsFile = [bundle URLForResource:@"bodymovin.min" withExtension:@"js"];
    NSData *jsData = [NSData dataWithContentsOfURL:jsFile];
    
    NSDictionary *props = @{
            (__bridge NSString *)kQLPreviewPropertyTextEncodingNameKey : @"UTF-8",
            (__bridge NSString *)kQLPreviewPropertyMIMETypeKey : @"text/html",
            (__bridge NSString *)kQLPreviewPropertyAttachmentsKey : @{
                    @"bodymovin.min.js" : @{
                            (__bridge NSString *)kQLPreviewPropertyMIMETypeKey : @"text/javascript",
                            (__bridge NSString *)kQLPreviewPropertyAttachmentDataKey: jsData,
                            },
                    },
            };
    
    return props;
}
@end
