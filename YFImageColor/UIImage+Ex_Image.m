
#import "UIImage+Ex_Image.h"

@implementation UIImage (Ex_Image)

/**
修改二维码图片颜色
*/
- (UIImage *)ChangeColorRGBA
{
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    // 第一步：判断传入的rect是否在图片的bounds内
    CGRect canvas = CGRectMake(0, 0, self.size.width, self.size.height);
    if (!CGRectContainsRect(canvas, rect)) {
        if (CGRectIntersectsRect(canvas, rect)) {
            rect = CGRectIntersection(canvas, rect);    // 取交集
        } else {
            return self;
        }
    }
  
    
    UIImage *transImage = nil;
    
    int imageWidth = self.size.width;
    int imageHeight = self.size.height;
    
    // 第二步：创建色彩空间、画布上下文，并将图片以bitmap（不含alpha通道）的方式画在画布上。
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    // 第三步：遍历并修改像素
    uint32_t *pCurPtr = rgbImageBuf;
    pCurPtr += (long)(rect.origin.y*imageWidth);    // 将指针移动到初始行的起始位置
    
    // 空间复杂度：O(rect.size.width * rect.size.height)
    for (int i = rect.origin.y; i < CGRectGetMaxY(rect); i++) {                     // row
        pCurPtr += (long)rect.origin.x;             // 将指针移动到当前行的起始列
        
        for (int j = rect.origin.x; j < CGRectGetMaxX(rect); j++, pCurPtr++) {      // column
     
            uint8_t *ptr = (uint8_t *)pCurPtr;
           // BOOL isBlack = *pCurPtr == nearWhiteRGBA || *pCurPtr == 0xfbfbfb ;//|| *pCurPtr > 254;
           // BOOL isWhite = ptr[1] > 240 || ptr[2] == 240 || ptr[3] == 240 ;//|| *pCurPtr > 254;
            BOOL isBlack = ptr[1] < 10 || ptr[2] < 10 || ptr[3] < 10 ;//|| *pCurPtr > 254;

            //   NSLog(@"%d",*pCurPtr);
            BOOL isLeftTop = j <= rect.size.width/2 && isBlack && i <= rect.size.height/2;
            BOOL isLeftBottom = j <= rect.size.width/2 && isBlack && i > rect.size.height/2;
            BOOL isLefRightTop = j > rect.size.width/2 && isBlack && i <= rect.size.height/2;
            BOOL isLefRightBottom = j > rect.size.width/2 && isBlack && i > rect.size.height/2;
            
            if(isLeftTop){
//                uint8_t *ptr = (uint8_t *)pCurPtr;
//                ptr[3] = //(transRGBA >> 24) & 0xFF;              // R
//                ptr[2] = (transRGBA >> 16) & 0xFF;              // G
//                ptr[1] = (transRGBA >> 8)  & 0xFF;              // B
//                ptr[0] = 0;
                // 将图片转成想要的颜色
                *pCurPtr = 0xfed545FF;
            }
            if(isLeftBottom){
                *pCurPtr = 0x000000FF;
                *pCurPtr = 0xfed545FF;

            }
            if(isLefRightTop){
                *pCurPtr = 0xfed545FF;
                
                *pCurPtr = 0xfed545FF;


            }
            if(isLefRightBottom){
                *pCurPtr = 0x26AA48FF;
                *pCurPtr = 0xfed545FF;


            }
        }
        pCurPtr += (long)(imageWidth - CGRectGetMaxX(rect));    // 将指针移动到下一行的起始列
    }
 
    
    
    // 第四步：输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, providerReleaseDataCallback);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    transImage = [UIImage imageWithCGImage:imageRef];
    
    // end：清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
//    //7.1开启图形上下文
//    UIGraphicsBeginImageContext(rect.size);
//    [transImage drawInRect: rect];
//    //暂时不用太小 像素小模糊
////    UIImage *centerImg=[UIImage imageNamed:@"logo"];
////    CGFloat centerW=rect.size.width/3;
////    CGFloat centerH=centerW;
////    CGFloat centerX=(rect.size.width-centerW)*0.5;
////    CGFloat centerY=(rect.size.height-centerH)*0.5;
//   // [centerImg drawInRect:CGRectMake(centerX, centerY, centerW, centerH)];
//    //7.4获取绘制好的图片
//    UIImage *finalImg=UIGraphicsGetImageFromCurrentImageContext();
//    
//    //7.5关闭图像上下文
//    UIGraphicsEndImageContext();
    return transImage ? : self;
}

void providerReleaseDataCallback (void *info, const void *data, size_t size) {
    free((void*)data);
}
@end
