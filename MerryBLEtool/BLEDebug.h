//
//  BLEDebug.h
//  MerryBLEtool
//
//  Created by merry on 13-12-24.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#ifndef MerryBLEtool_BLEDebug_h
#define MerryBLEtool_BLEDebug_h

#define xDEBUG_PRINT_ENABLE

#ifdef DEBUG_PRINT_ENABLE
    //#define DEBUG(x) {printf x;}
    #define DEBUG_BLETask
    #define DEBUG_ViewControl
#endif

#endif
