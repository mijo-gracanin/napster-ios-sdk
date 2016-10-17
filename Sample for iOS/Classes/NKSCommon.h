//
//  NKSCommon.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#define rs_weakify(variable) autoreleasepool{}\
    __typeof__(variable) __weak _weak_ ## variable = (variable);

#define rs_strongify(variable) autoreleasepool{}\
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    __typeof__(variable) __strong variable = _weak_ ## variable;\
    _Pragma("clang diagnostic pop")
