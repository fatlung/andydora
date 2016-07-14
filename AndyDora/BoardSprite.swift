//
//  BoardSprite.swift
//  AndyDora
//
//  Created by AU HO CHUN on 7/9/16.
//  Copyright © 2016 fatlungau. All rights reserved.
//

import SpriteKit

let kDropAnimationTimeInterval : NSTimeInterval = 0.5
let kDropFadeOutAnimationTimeInterval : NSTimeInterval = 0.5
let kDropSwappingAnimationTimeInterval : NSTimeInterval = 0.1

class BoardSprite: SKSpriteNode {

    var boardConfiguration : BoardConfiguration
    var touchedSpriteOrigin : CGPoint?
    var boardController : BoardController
    var dropSprite2dArray : [[DropSprite]]?
    var dropSpritePositions2dArray :[[CGPoint]]?
    
    var touchedNode : SKNode? {
        didSet {
            self.touchedSpriteOrigin = self.touchedNode?.position
        }
    }
    
     init (width:CGFloat, boardController:BoardController) {
        
        self.boardController = boardController
        self.boardConfiguration = self.boardController.boardConfiguration
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSizeMake(width, width/CGFloat(boardConfiguration.size.width)*CGFloat(boardConfiguration.size.height)))
        self.anchorPoint = CGPointMake(0,0)
        self.position = frame.origin
        
        let dropWidth : CGFloat = frame.width/CGFloat(boardConfiguration.size.width)
        let dropHeight : CGFloat = frame.height/CGFloat(boardConfiguration.size.height)
        
        self.dropSprite2dArray = [[DropSprite]]()
        self.dropSpritePositions2dArray = [[CGPoint]]()
        for i : Int in 0..<boardConfiguration.size.width {
            var spriteColumnArray = [DropSprite]()
            var positionColumnArray = [CGPoint]()
            for j : Int in 0..<boardConfiguration.size.height {
                
                let dropData = self.boardController[i,j] as DropData?
                let dropSprite = DropSpriteFactory.dropSpriteWithType((dropData?.dropType)!)
                dropSprite.anchorPoint = CGPointMake(0.5,0.5)
                dropSprite.position = CGPointMake(CGFloat(i)*(dropWidth) + dropWidth/2, CGFloat(j)*dropHeight +  dropHeight/2)
                dropSprite.size = CGSizeMake(dropWidth, dropHeight)
                dropSprite.name = dropData?.coordinate.toString()
                self.addChild(dropSprite)
                spriteColumnArray.append(dropSprite)
                positionColumnArray.append(dropSprite.position)
            }
            self.dropSprite2dArray?.append(spriteColumnArray)
            self.dropSpritePositions2dArray?.append(positionColumnArray)
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        self.boardConfiguration = BoardConfiguration(boardType:BoardType.BoardType5Colors, size:Size(width:0, height:0))
        self.boardController = BoardController(boardConfiguration:self.boardConfiguration)
        super.init(coder: aDecoder)
    }

    
    func randomDrop(boardType:BoardType) -> DropSprite {
    
        let randomNumber : Int = Int(arc4random())
        let modNumber : Int = boardType.rawValue;
        let dropSprite : DropSprite
        switch (randomNumber%modNumber) {
        case DropType.DropTypeFire.rawValue:
            dropSprite = FireDropSprite()
            break;
        case DropType.DropTypeWater.rawValue:
            dropSprite = WaterDropSprite()
            break;
        case DropType.DropTypeWood.rawValue:
            dropSprite = WoodDropSprite()
            break;
        case DropType.DropTypeLight.rawValue:
            dropSprite = LightDropSprite()
            break;
        case DropType.DropTypeDark.rawValue:
            dropSprite = DarkDropSprite()
            break;
        case DropType.DropTypeHeart.rawValue:
            dropSprite = HeartDropSprite()
            break;
        case DropType.DropTypeRubbish.rawValue:
            dropSprite = RubbishDropSprite()
            break;
        case DropType.DropTypeToxic.rawValue:
            dropSprite = ToxicDropSprite()
            break;
        case DropType.DropTypeVeryToxic.rawValue:
            dropSprite = VeryToxicDropSprite()
            break;
        default:
            dropSprite = FireDropSprite()
        }
        
        return dropSprite
    }
    
    func swapSpriteForPoint(location: CGPoint) {
        
        self.touchedNode?.position = location
        if let movingSpriteCenter = self.touchedNode?.position {
            for dropSprite : SKNode in self.children {
                if (dropSprite.containsPoint(movingSpriteCenter) && dropSprite != self.touchedNode) {
                    if !dropSprite.hasActions() {
                        // swap data
                        self.boardController.swapTwoCoordinates(Coordinate(string:(self.touchedNode?.name)!), coordinate2: Coordinate(string:dropSprite.name!))
                        // swap the coordinate
                        let tempString = (self.touchedNode?.name)! as String
                        self.touchedNode?.name = dropSprite.name!
                        dropSprite.name = tempString
                        
                        let movedSpriteOrigin = self.touchedSpriteOrigin!
                        self.touchedSpriteOrigin = dropSprite.position
                        self.swapTwoCoordinates(Coordinate(string:(self.touchedNode?.name)!), coordinate2: Coordinate(string:dropSprite.name!))
                        dropSprite.runAction(SKAction.moveTo(movedSpriteOrigin, duration: kDropSwappingAnimationTimeInterval), completion: { () -> Void in
                            NSLog("%@", (self.dropSprite2dArray?.description)!)
                        })
                        break;
                    }
                }
            }
        }
    }
    
    
    func swapTwoCoordinates(coordinate1:Coordinate, coordinate2:Coordinate) {
        
        let dropSprite1 = self.childNodeWithName(coordinate1.toString()) as! DropSprite
        let dropSprite2 = self.childNodeWithName(coordinate2.toString()) as! DropSprite
        self.dropSprite2dArray?[coordinate1.x][coordinate1.y] = dropSprite1
        self.dropSprite2dArray?[coordinate2.x][coordinate2.y] = dropSprite2
        //NSLog("%@", (self.dropSprite2dArray?.description)!)
    }
    
    func snapToPositionWhenEnd() {
        
        self.touchedNode?.runAction(SKAction.moveTo(self.touchedSpriteOrigin!, duration: kDropSwappingAnimationTimeInterval), completion: { () -> Void in
            self.touchedNode = nil
            self.solveBoard()
        })
    }
    
    
    func solveBoard() {
        let boardSolutionDictionary = self.boardController.solveBoard()
        let allSolutions = self.allSolutionsFromSolvedBoardDictionary(boardSolutionDictionary)
        var actions = [SKAction]()
        for solution in allSolutions {
            actions.append(self.groupedAnimtaionsForBoardSolution(solution))
            actions.append(SKAction.waitForDuration(0.5))
        }
        if actions.count > 0 {
            self.runAction(SKAction.sequence(actions), completion: { () -> Void in
                NSLog("finish solve board")
                self.clearForNextSolve(allSolutions)
            })
        }
    }
    
    
    
    
    func clearForNextSolve(solutions:[BoardSolution]) {
        self.boardController.removeSolutionsFromBoard(solutions)
        self.boardController.reassignCoordinateForBoard()
//        let removingCoordinates =  solutions.map { (boardSolution:BoardSolution) -> [Coordinate] in
//            return boardSolution.coordinates
//            }.flatMap{$0}
//        
        self.removeSpriteFromSolutions(solutions)
        
        // reassign coordinate and give animation
        var spriteAnimations = [SKAction]()
        for i in 0..<self.boardConfiguration.size.width {
            let columnArray = self.dropSprite2dArray?[i]
            for j in 0..<self.boardConfiguration.size.height {
                
                if let count = columnArray?.count {
                    if j < count {
                        let dropSprite = columnArray![j]
                        let oldCoordinate = Coordinate(string:dropSprite.name!)
                        dropSprite.name = Coordinate(x:i, y:j).toString()
                        if oldCoordinate == Coordinate(x:i, y:j) {
                            continue
                        } else {
                            let coordinate = self.dropSpritePositions2dArray?[i][j]
                            let action = SKAction.moveTo(coordinate!, duration: kDropAnimationTimeInterval)
                            action.timingMode = .EaseOut
                            spriteAnimations.append(SKAction.runAction(action, onChildWithName:dropSprite.name!))
                            
                        }
                    }
                }
                
            }
            
        }
        let groupAction = SKAction.group(spriteAnimations)
        self.runAction(SKAction.sequence([groupAction,
                                    SKAction.waitForDuration(kDropAnimationTimeInterval),
            SKAction.runBlock({ () -> Void in
                self.solveBoard()
            })])
            )
        
    }
    
    func removeSpriteFromSolutions(solutions:[BoardSolution]) {
        
        for solution in solutions {
            for coordinate in solution.coordinates {
                if let drops = self.dropSprite2dArray?[coordinate.x] { //column
                    let filteredDrops = drops.filter({ (dropSprite :DropSprite) -> Bool in
                        if dropSprite.name == coordinate.toString() {
                            dropSprite.removeFromParent()
                            return false
                        } else {
                            return true
                        }
                    })
                    self.dropSprite2dArray?[coordinate.x] = filteredDrops
                }
            }
        }
    }
    
    
    
    func allSolutionsFromSolvedBoardDictionary(boardSolutionDictionary:[DropType:[BoardSolution]]) -> [BoardSolution] {
    
        var solutions = [BoardSolution]()
        for boardSolutions in boardSolutionDictionary.values {
            solutions.appendContentsOf(boardSolutions)
        }
        return solutions
    }
    
    func groupedAnimtaionsForBoardSolution(solution:BoardSolution) -> SKAction {
        
        var actions = [SKAction]()
        for coordinate in solution.coordinates {
            let action = SKAction.fadeOutWithDuration(kDropFadeOutAnimationTimeInterval)
            action.timingMode = .EaseInEaseOut
            actions.append(SKAction.runAction(action, onChildWithName: coordinate.toString()))
        }
        return SKAction.group(actions)
        
    }
    

    
}
