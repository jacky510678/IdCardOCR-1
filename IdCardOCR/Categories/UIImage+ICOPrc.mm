//
//  UIImage+ICOPrc.m
//  IdCardOCR
//
//  Created by Hua Xiong on 16/3/8.
//  Copyright © 2016年 ivoryxiong. All rights reserved.
//

#import "UIImage+ICOPrc.h"

@implementation UIImage (ICOPrc)

typedef NS_ENUM(NSUInteger, PIXELS) {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
};

- (UIImage *)ico_darkWhiteImage:(CGFloat )fuzz {
        CGSize size = [self size];
        int width = size.width;
        int height = size.height;
        
        // the pixels will be painted to this array
        uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
        
        // clear the pixels so any transparency is preserved
        memset(pixels, 0, width * height * sizeof(uint32_t));
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // create a context with RGBA pixels
        CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                     kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
        
        // paint the bitmap to our context which will fill in the pixels array
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
        
        for(int y = 0; y < height; y++) {
            for(int x = 0; x < width; x++) {
                uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
                
                // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
                
                if (rgbaPixel[RED] * rgbaPixel[RED] + rgbaPixel[BLUE] * rgbaPixel[BLUE] + rgbaPixel[GREEN] * rgbaPixel[GREEN]
                    > 255 * fuzz * 255 * fuzz * 3) {
                    rgbaPixel[RED] = rgbaPixel[GREEN] = rgbaPixel[BLUE] = 255;
                } else {
                    uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
                    rgbaPixel[RED] = rgbaPixel[GREEN] = rgbaPixel[BLUE] = gray;
                }
//
//                // set the pixels to gray
//                rgbaPixel[RED] = gray;
//                rgbaPixel[GREEN] = gray;
//                rgbaPixel[BLUE] = gray;
//                rgbaPixel[GREEN] = 0;
//                rgbaPixel[BLUE] = 0;
            }
        }
        
        // create a new CGImageRef from our context with the modified pixels
        CGImageRef image = CGBitmapContextCreateImage(context);
        
        // we're done with the context, color space, and pixels
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        free(pixels);
        
        // make a new UIImage to return
        UIImage *resultUIImage = [UIImage imageWithCGImage:image scale:0 orientation:self.imageOrientation];
        
        // we're done with image now too
        CGImageRelease(image);
        
        return resultUIImage;

}
@end