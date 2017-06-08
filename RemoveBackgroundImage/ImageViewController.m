//
//  ImageViewController.m
//  RemoveBackgroundImage
//
//  Created by Elian Medeiros on 07/06/17.
//  Copyright © 2017 Elian Medeiros. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    UIImage *image = [UIImage imageNamed:@"nota"];
    image = [self changeWhiteColorTransparent:image];
    image = [self imageWithContrast:2 image:image];

    [_imageView setImage:image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIImage *) imageWithContrast:(CGFloat)contrastFactor image:(UIImage *)image {
    
    if(contrastFactor == 1) {
        return image;
    }
    
    CGImageRef imgRef = [image CGImage];
    
    size_t width = CGImageGetWidth(imgRef);
    size_t height = CGImageGetHeight(imgRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 4;
    size_t bytesPerRow = bytesPerPixel * width;
    size_t totalBytes = bytesPerRow * height;
    
    //Allocate Image space
    uint8_t *rawData = malloc(totalBytes);
    
    //Create Bitmap of same size
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //Draw our image to the context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    
    //Perform Brightness Manipulation
    for(int i = 0; i < totalBytes; i += 4) {
        
        uint8_t *red = rawData + i;
        uint8_t *green = rawData + (i + 1);
        uint8_t *blue = rawData + (i + 2);
        
        *red = MIN(255,MAX(0, roundf(contrastFactor*(*red - 127.5f)) + 128));
        *green = MIN(255,MAX(0, roundf(contrastFactor*(*green - 127.5f)) + 128));
        *blue = MIN(255,MAX(0, roundf(contrastFactor*(*blue - 127.5f)) + 128));
        
    }
    
    //Create Image
    CGImageRef newImg = CGBitmapContextCreateImage(context);
    
    //Release Created Data Structs
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(rawData);
    
    //Create UIImage struct around image
    UIImage *imageFinal = [UIImage imageWithCGImage:newImg];
    
    //Release our hold on the image
    CGImageRelease(newImg);
    
    //return new image!
    return imageFinal;
    
}

- (UIImage *)changeWhiteColorTransparent: (UIImage *)image {
    CGImageRef rawImageRef=image.CGImage;
    
    const CGFloat colorMasking[6] = {200, 255, 200, 255, 200, 255};
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef = CGImageCreateWithMaskingColors(rawImageRef, colorMasking); {
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}

@end
