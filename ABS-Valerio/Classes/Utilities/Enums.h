#import <Foundation/Foundation.h>

#ifndef Enums_h
#define Enums_h

typedef NS_ENUM(NSInteger, FontType){
    Bold,
    Book,
    Light,
    Regular,
    Thin,
    Nike
};

typedef NS_ENUM(NSInteger, PreviewType){
    NoPreview = 0,
    ShortPreview = 5,
    FullPreview = 10
};

#endif /* Enums_h */
