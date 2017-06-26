//
//  AJMPDefinitionHeader.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/1.
//  Copyright © 2017年 AJ. All rights reserved.
//

#ifndef AJMPDefinitionHeader_h
#define AJMPDefinitionHeader_h

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

#define Ratio_Width (SCREEN_WIDTH/375.0)
#define Ratio_Height (SCREENH_HEIGHT/667.0)

#define AJRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

#define AJMPMediaCellCountOneLine 3

#define AJMPContentViewBackgroundColor [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1]


#endif /* AJMPDefinitionHeader_h */
