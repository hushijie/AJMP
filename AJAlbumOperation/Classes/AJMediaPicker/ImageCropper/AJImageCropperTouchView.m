//
//  AJImageCropperTouchView.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/19.
//  Copyright © 2017年 AJ. All rights reserved.
//

#import "AJImageCropperTouchView.h"

@implementation AJImageCropperTouchView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event]) {
        return self.receiver;
    }
    return nil;
}

@end
