//
//  UIImage+Category.m
//  Juanpi_2.0
//
//  Created by luoshuai on 14-2-24.
//  Copyright (c) 2014年 Juanpi. All rights reserved.
//

#import "UIImage+Category.h"
#import <Accelerate/Accelerate.h>

#define QMScreenWidth [UIScreen mainScreen].bounds.size.width //屏幕宽
#define QMScreenHeight [UIScreen mainScreen].bounds.size.height //屏幕高

#define MAX_UPLOAD_IMG_WIDTH (QMScreenWidth)
#define MAX_UPLOAD_IMG_HEIGHT (QMScreenHeight)

//图片上传的最大尺寸
#define MAX_UPLOAD_IMG_FILESIZE 100000


@implementation UIImage (Category)

+ (UIImage *)resizableImage:(NSString *)name
{
    UIImage *normal = [UIImage imageNamed:name];
    return [normal stretchableImageWithLeftCapWidth:normal.size.width/2 topCapHeight:normal.size.height/2];
}

//+ (UIImage *) captureScreen {
//    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
//    CGRect rect = [keyWindow bounds];
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [keyWindow.layer renderInContext:context];
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return img;
//}

+ (UIImage *)compressionWithImage:(UIImage *)image toSize:(CGSize )size
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(size);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [UIImage imageWithColor:color size:CGSizeMake(1.0f, 1.0f)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    
    if (!color) {
        return nil;
    }
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//==========================================================================


//压缩要上传的图片
+ (UIImage *)imageWithImageUpload:(UIImage *)image scale:(CGFloat)scale
{
    UIImage *theImage = image;
    NSData *theData = nil;
    
    //如果不是长图,压缩尺寸
    if(![UIImage isLongImage:theImage]){
        theImage = [UIImage imageWithImageFileSize:theImage scale:scale];
    }
    
    //再压缩图片质量
    theData = [UIImage imageWithImageRepresentation:theImage];
    
    UIImage *uploadImage = [UIImage imageWithData:theData];
    
    return uploadImage;
}

//压缩要上传的图片
+ (NSData *)dataWithImageUpload:(UIImage *)image scale:(CGFloat)scale
{
    UIImage *theImage = image;
    NSData *theData = nil;
    
    //如果不是长图,压缩尺寸
    if(![UIImage isLongImage:theImage]){
        theImage = [UIImage imageWithImageFileSize:theImage scale:scale];
    }
    
    //再压缩图片质量
    theData = [UIImage imageWithImageRepresentation:theImage];
    
    return theData;
}


//是否是长图
+ (BOOL)isLongImage:(UIImage *)image
{
    if((image.size.height > 2*image.size.width)||(image.size.width > 2*image.size.height))
    {
        return YES;
    }
    return NO;
}

//按图片大小压缩图片尺寸
+ (UIImage *)imageWithImageFileSize:(UIImage *)image scale:(CGFloat)scale
{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    if(data == nil)data = UIImagePNGRepresentation(image);
    
    UIImage *newImage = image;
    if(data.length > MAX_UPLOAD_IMG_FILESIZE)
    {
        if(newImage.size.width > MAX_UPLOAD_IMG_WIDTH * scale && newImage.size.width>newImage.size.height)
        {
            CGSize size = CGSizeMake(MAX_UPLOAD_IMG_WIDTH * scale, MAX_UPLOAD_IMG_WIDTH *scale * newImage.size.height/newImage.size.width);
            newImage = [UIImage compressionWithImage:newImage toSize:size];
            
        }
        else if(newImage.size.height>MAX_UPLOAD_IMG_HEIGHT * scale && newImage.size.height>newImage.size.width)
        {
            CGSize size = CGSizeMake(MAX_UPLOAD_IMG_HEIGHT * scale * newImage.size.width/newImage.size.height, MAX_UPLOAD_IMG_HEIGHT * scale);
            newImage = [UIImage compressionWithImage:newImage toSize:size];
        }
        else
        {
            CGSize size = CGSizeMake( scale * newImage.size.width, scale *newImage.size.height);
            newImage = [UIImage compressionWithImage:newImage toSize:size];
        }
    }
    
    return newImage;
}


//再压缩图片质量
+ (NSData *)imageWithImageRepresentation:(UIImage *)image
{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    if(data == nil){
        data = UIImagePNGRepresentation(image);
        return data;
    }
    
    NSData *theData = nil;
    
    if(data.length > MAX_UPLOAD_IMG_FILESIZE)
    {
        float percent = [UIImage getImgRepresentation:image];
        
        theData = UIImageJPEGRepresentation(image, percent);
        return theData;
        
    }
    return data;
}

//获取图片压缩的百分比
+ (CGFloat)getImgRepresentation:(UIImage *)image
{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    if(data == nil)return 1;
    
    CGFloat percent = 1;
    
    while(data.length > MAX_UPLOAD_IMG_FILESIZE)//压缩图片质量
    {
        percent -= 0.1;
        data = UIImageJPEGRepresentation(image, percent);
        
        if(data.length < MAX_UPLOAD_IMG_FILESIZE || percent<=0.1){
            break;
        }
    }
    
    return percent;
}
//==========================================================================


+ (UIImage *)imageWithShareImage:(UIImage *)image {
    
    //压缩图片质量
    NSData *newData = UIImageJPEGRepresentation(image, 0.1);
    if(newData == nil){
        return image;
    }
    
    UIImage *newImage = [UIImage imageWithData:newData];
    
    CGSize size = CGSizeZero;
    //压缩图片尺寸
    if(newImage.size.width > newImage.size.height) {
        size = CGSizeMake(200, 200 * newImage.size.height/newImage.size.width);
    }
    else {
        size = CGSizeMake(200 * newImage.size.width/newImage.size.height, 200);
    }
    
    newImage = [UIImage compressionWithImage:newImage toSize:size];
    
    return newImage;
}


+ (NSData *)dataWithShareImage:(UIImage *)image {
    NSData *newData = UIImageJPEGRepresentation(image, 0.1);
    if (!newData) {
        newData = UIImagePNGRepresentation(image);
    }
    
    return newData;
}

//- (UIImage *)blurryImageBlurLevel:(CGFloat)blur {
//    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
//    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
//                                  keysAndValues:kCIInputImageKey, inputImage,
//                        @"inputRadius", @(blur),
//                        nil];
//    
//    CIImage *outputImage = filter.outputImage;
//    
//    CGImageRef outImage = [self.context createCGImage:outputImage
//                                             fromRect:[outputImage extent]];
//    return [UIImage imageWithCGImage:outImage];
//}

- (UIImage *)cropImageInRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:self.imageOrientation].CGImage, CGRectMake(rect.origin.x * self.scale, rect.origin.y * self.scale, rect.size.width * self.scale, rect.size.height * self.scale));
    UIImage *cropImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return cropImage;
}

- (NSString *)base64String {
    NSData *data = UIImageJPEGRepresentation(self, 0.5);
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end

@implementation UIImage(ImageEffects)
- (UIImage*)applyLightEffect {
    UIColor*tintColor =[UIColor colorWithWhite:1.0 alpha:0.3];
    return[self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage*)applyExtraLightEffect {
    UIColor*tintColor =[UIColor colorWithWhite:0.97 alpha:0.82];
    return[self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage*)applyDarkEffect {
    UIColor*tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return[self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyTintEffectWithColor:(UIColor*)tintColor {
    const CGFloat EffectColorAlpha = 0.6;
    UIColor*effectColor = tintColor;
    size_t componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if(componentCount == 2){
        CGFloat b;
        if([tintColor getWhite:&b alpha:NULL]){
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else{
        CGFloat r, g, b;
        if([tintColor getRed:&r green:&g blue:&b alpha:NULL]){
            effectColor =[UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self applyBlurWithRadius:10 tintColor:effectColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage*)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage*)maskImage
{
    // Check pre-conditions.
    if(self.size.width <1||self.size.height <1){
        NSLog(@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@",self.size.width,self.size.height,self);
        return nil;
    }
    if(!self.CGImage){
        NSLog(@"*** error: image must be backed by a CGImage: %@",self);
        return nil;
    }
    if(maskImage &&!maskImage.CGImage){
        NSLog(@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    CGRect imageRect ={CGPointZero,self.size };
    UIImage*effectImage =self;
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor -1.)> __FLT_EPSILON__;
    if(hasBlur || hasSaturationChange){
        UIGraphicsBeginImageContextWithOptions(self.size, NO,[[UIScreen mainScreen] scale]);
        CGContextRef effectInContext =UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext,1.0,-1.0);
        CGContextTranslateCTM(effectInContext,0,-self.size.height);
        CGContextDrawImage(effectInContext, imageRect,self.CGImage);
        vImage_Buffer effectInBuffer;
        effectInBuffer.data =CGBitmapContextGetData(effectInContext);
        effectInBuffer.width =CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height =CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes =CGBitmapContextGetBytesPerRow(effectInContext);
        UIGraphicsBeginImageContextWithOptions(self.size, NO,[[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext =UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data =CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width =CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height =CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes =CGBitmapContextGetBytesPerRow(effectOutContext);
        if(hasBlur){
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius *[[UIScreen mainScreen] scale];
            uint32_t radius = floor(inputRadius *3.* sqrt(2* M_PI)/4+0.5);
            if(radius %2!=1){
                radius +=1;// force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer,&effectOutBuffer, NULL,0,0, radius, radius,0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer,&effectInBuffer, NULL,0,0, radius, radius,0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer,&effectOutBuffer, NULL,0,0, radius, radius,0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if(hasSaturationChange){
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[]={
                0.0722+0.9278* s,0.0722-0.0722* s,0.0722-0.0722* s,0,
                0.7152-0.7152* s,0.7152+0.2848* s,0.7152-0.7152* s,0,
                0.2126-0.2126* s,0.2126-0.2126* s,0.2126+0.7873* s,0,
                0,0,0,1,
            };
            const int32_t divisor =256;
            NSUInteger matrixSize =sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for(NSUInteger i =0; i < matrixSize;++i){
                saturationMatrix[i]=(int16_t)roundf(floatingPointSaturationMatrix[i]* divisor);
            }
            if(hasBlur){
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer,&effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else{
                vImageMatrixMultiply_ARGB8888(&effectInBuffer,&effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if(!effectImageBuffersAreSwapped)
            effectImage =UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if(effectImageBuffersAreSwapped)
            effectImage =UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO,[[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext,1.0,-1.0);
    CGContextTranslateCTM(outputContext,0,-self.size.height);
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect,self.CGImage);
    // Draw effect image.
    if(hasBlur){
        CGContextSaveGState(outputContext);
        if(maskImage){
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    // Add in color tint.
    if(tintColor){
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    // Output image is ready.
    UIImage*outputImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}
@end
