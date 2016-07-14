//
//  DropSprite.swift
//  FLHand
//
//  Created by AU HO CHUN on 7/9/16.
//  Copyright © 2016 fatlungau. All rights reserved.
//

import SpriteKit
import UIKit

let kDropTextureSizeHeight : CGFloat = 183
let kDropTextureSizeWidth  : CGFloat = 449
let kDropWidth : CGFloat = kDropTextureSizeWidth/5.0
let kDropHeight : CGFloat = kDropTextureSizeHeight/2.0
let kDropWidthRatio : CGFloat = 0.2 // 1/5
let kDropHeightRatio : CGFloat = 0.5 // 1/2

enum DropType : Int {
   case DropTypeFire = 0
   case DropTypeWater = 1
   case DropTypeWood = 2
   case DropTypeLight = 3
   case DropTypeDark = 4
   case DropTypeHeart = 5
   case DropTypeRubbish = 6
   case DropTypeToxic = 7
   case DropTypeVeryToxic = 8
}


class DropSprite: SKSpriteNode {

    let dropTextureImage : String = "dokus"
    var dropType : DropType?
    
    init(dropRect:CGRect) {
        
        let texture = SKTexture(imageNamed: dropTextureImage)
        
        let dropTexture = SKTexture(rect:dropRect, inTexture:texture)
        super.init(texture: dropTexture, color: UIColor.clearColor(), size: CGSizeMake(kDropWidth, kDropHeight))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override var description : String  {
        return self.name!
    }

    
}


class FireDropSprite : DropSprite {
    
    init() {
        super.init(dropRect: CGRectMake(0, kDropHeightRatio, kDropWidthRatio, kDropHeightRatio))
        self.dropType = .DropTypeFire
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class WaterDropSprite : DropSprite {
    
    init() {
        super.init(dropRect: CGRectMake(kDropWidthRatio*1, kDropHeightRatio, kDropWidthRatio, kDropHeightRatio))
        self.dropType = .DropTypeWater

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class WoodDropSprite : DropSprite {
    
    init() {
        super.init(dropRect: CGRectMake(kDropWidthRatio*2, kDropHeightRatio, kDropWidthRatio, kDropHeightRatio))
        self.dropType = .DropTypeWood

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class LightDropSprite : DropSprite {
    
    init() {
        super.init(dropRect: CGRectMake(kDropWidthRatio*3, kDropHeightRatio, kDropWidthRatio, kDropHeightRatio))
        self.dropType = .DropTypeLight

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class DarkDropSprite : DropSprite {
    
    init() {
        super.init(dropRect: CGRectMake(0, 0, kDropWidthRatio, kDropHeightRatio))
        self.dropType = .DropTypeDark

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class RubbishDropSprite : DropSprite {
    
    init() {
        super.init(dropRect: CGRectMake(kDropWidthRatio*1, 0, kDropWidthRatio, kDropHeightRatio))
        self.dropType = .DropTypeRubbish

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class HeartDropSprite : DropSprite {
    
    init() {
        super.init(dropRect: CGRectMake(kDropWidthRatio*2, 0, kDropWidthRatio, kDropHeightRatio))
        self.dropType = .DropTypeHeart

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ToxicDropSprite : DropSprite {
    
    init() {
        super.init(dropRect: CGRectMake(kDropWidthRatio*3, 0, kDropWidthRatio, kDropHeightRatio))
        self.dropType = .DropTypeToxic

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class VeryToxicDropSprite : DropSprite {
    
    init() {
        super.init(dropRect: CGRectMake(kDropWidthRatio*4, 0, kDropWidthRatio, kDropHeightRatio))
        self.dropType = .DropTypeVeryToxic
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class DropSpriteFactory : NSObject {

    class func dropSpriteWithType(type:DropType) -> DropSprite
    {
        let dropSprite : DropSprite?
        switch (type) {
        case .DropTypeFire:
            dropSprite = FireDropSprite()
        case .DropTypeWater:
            dropSprite = WaterDropSprite()
        case .DropTypeWood:
            dropSprite = WoodDropSprite()
        case .DropTypeLight:
            dropSprite = LightDropSprite()
        case .DropTypeDark:
            dropSprite = DarkDropSprite()
        case .DropTypeHeart:
            dropSprite = HeartDropSprite()
        case .DropTypeRubbish:
            dropSprite = RubbishDropSprite()
        case .DropTypeToxic:
            dropSprite = ToxicDropSprite()
        case .DropTypeVeryToxic:
            dropSprite = ToxicDropSprite()
        }
        
        return dropSprite!
    }
}

