#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <AppKit/AppKit.h>
#include <Cocoa/Cocoa.h>
#include <QuartzCore/QuartzCore.h>

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    
    CGContextRef _context = QLThumbnailRequestCreateContext(thumbnail, maxSize, false, NULL);
    if (_context) {
        
        CGContextSetFillColorWithColor(_context, [NSColor blackColor].CGColor);
        CGContextFillRect(_context, CGRectMake(0, 0, maxSize.width, maxSize.height));
        
        
        CFStringRef string = (__bridge CFStringRef)@"json";
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)@"Helvetica", 32.0f, &CGAffineTransformIdentity);
        CGColorRef fontColor = [NSColor whiteColor].CGColor;
        
        CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
        CFTypeRef values[] = { font, fontColor };
        
        CFDictionaryRef attributes =
        CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                           (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                           &kCFTypeDictionaryKeyCallBacks,
                           &kCFTypeDictionaryValueCallBacks);
        
        CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
        CTLineRef line = CTLineCreateWithAttributedString(attrString);
        CGRect lineBounds = CTLineGetBoundsWithOptions(line, kCTLineBoundsUseGlyphPathBounds);
        
        CGFloat xScale = (maxSize.width*0.5)/lineBounds.size.width;
        CGFloat yScale = xScale;
        
        CGContextSetTextPosition(_context, 10.0, 10.0);
        CGContextScaleCTM(_context, xScale, yScale);
        CTLineDraw(line, _context);
        
        QLThumbnailRequestFlushContext(thumbnail, _context);
        
        CFRelease(_context);
        CFRelease(line);
        CFRelease(string);
        CFRelease(attributes);
        CFRelease(font);
    }
    
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
