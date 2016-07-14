//
//  DropData.swift
//  AndyDora
//
//  Created by AU HO CHUN on 7/10/16.
//  Copyright © 2016 fatlungau. All rights reserved.
//

import UIKit

class DropData: GridData {

    var dropType: DropType?
    
    
    override var description : String {
        return String(format:"(%d,%d) - type:%d", self.coordinate.x, self.coordinate.y, dropType!.rawValue)
    }
    
    
    class func dropTypesForBoardType(boardType:BoardType) -> [DropType] {
        
        switch(boardType) {
        case .BoardType5Colors:
            return [DropType.DropTypeFire,
                DropType.DropTypeWater,
                DropType.DropTypeWood,
                DropType.DropTypeLight,
                DropType.DropTypeDark,
            ]
        case .BoardType6Colors:
            return [DropType.DropTypeFire,
                DropType.DropTypeWater,
                DropType.DropTypeWood,
                DropType.DropTypeLight,
                DropType.DropTypeDark,
                DropType.DropTypeHeart,
            ]
        case .BoardTypeAllColors:
            return [DropType.DropTypeFire,
                DropType.DropTypeWater,
                DropType.DropTypeWood,
                DropType.DropTypeLight,
                DropType.DropTypeDark,
                DropType.DropTypeHeart,
                DropType.DropTypeRubbish,
                DropType.DropTypeToxic,
                DropType.DropTypeVeryToxic
            ]
        }
    }
    
}
