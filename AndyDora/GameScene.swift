//
//  GameScene.swift
//  AndyDora
//
//  Created by AU HO CHUN on 7/9/16.
//  Copyright (c) 2016 fatlungau. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
  
        let boardConfiguration =  BoardConfiguration(boardType:BoardType.BoardType5Colors, size: Size(width:6, height:5))
        let boardController = BoardController(boardConfiguration: boardConfiguration)
        let boardSprite = BoardSprite(width:view.frame.width, boardController:boardController)
        boardSprite.name = "board"
        self.addChild(boardSprite)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let boardSprite = self.childNodeWithName("board") as! BoardSprite
            if (boardSprite.containsPoint(location)) {
                for dropSprite : SKNode in boardSprite.children {
                    if (dropSprite.containsPoint(location) && !dropSprite.hasActions()) {
                        boardSprite.touchedNode = dropSprite
                        dropSprite.alpha = 0.8
                        dropSprite.xScale = 1.2
                        dropSprite.yScale = 1.2
                        dropSprite.zPosition = 1
                        dropSprite.position = location
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let boardSprite = self.childNodeWithName("board") as! BoardSprite
            if (boardSprite.containsPoint(location)) {
                boardSprite.swapSpriteForPoint(location)
            }
        }
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        for touch in touches {
            let location = touch.locationInNode(self)
            let boardSprite = self.childNodeWithName("board") as! BoardSprite
            if (boardSprite.containsPoint(location)) {
                let dropSprite : SKNode? = boardSprite.touchedNode
                if let sprite = dropSprite {
                    sprite.alpha = 1
                    sprite.xScale = 1
                    sprite.yScale = 1
                    sprite.zPosition = 0
                    boardSprite.snapToPositionWhenEnd()
                }
            }
        }
    }
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
