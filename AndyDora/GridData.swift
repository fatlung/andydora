//
//  GridData.swift
//  FatlungHand
//
//  Created by AU HO CHUN on 7/9/16.
//  Copyright © 2016 fatlungau. All rights reserved.
//

import UIKit

func ==(left:Coordinate, right:Coordinate) -> Bool {
    return (left.x == right.x) && (left.y == right.y)
}

struct Coordinate {
    var x: Int
    var y: Int
    
    func toString() -> String {
        return String(format: "%d-%d", arguments: [self.x,self.y])
    }
    
    init (string:String) {
        let array = string.componentsSeparatedByString("-")
        let xString = array[0] as String
        let yString = array[1] as String
        self.x = Int(xString)!
        self.y = Int(yString)!
    }
    
    init (x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    

}



struct Size {
    var width: Int
    var height: Int
}


class GridData: NSObject {

    var coordinate : Coordinate
    var nearByCoordinates : [Coordinate]?
    var gridColor : UIColor?
    var boardSize : Size?
    var enableDiagonal : Bool?
    
    init(coord:Coordinate, gridColor:UIColor, boardSize:Size, enableDiagonal: Bool) {
        
        self.coordinate = coord
        super.init()
        self.gridColor = gridColor
        self.boardSize = boardSize
        self.enableDiagonal = enableDiagonal
        self.nearByCoordinates = self.calculateNearByCoordinates(coord, boardSize:boardSize, enableDiagonal:enableDiagonal)
        
    }
   
    
    func calculateNearByCoordinates(coord:Coordinate, boardSize:Size, enableDiagonal:Bool) -> [Coordinate] {
        
        let maxY : Int = boardSize.height
        let minY : Int = 0
        let maxX : Int = boardSize.width
        let minX : Int = 0
        
        let gridX = coord.x
        let gridY = coord.y
        
        var array = [Coordinate]()
        if (gridX-1 >= minX) {
            // left
            let leftCoord = Coordinate(x: gridX-1, y: gridY)
            array.append(leftCoord)
        }
        if (gridY+1 <= maxY) {
            // top
            let topCoord = Coordinate(x: gridX, y: gridY+1)
            array.append(topCoord)
        }
        if (gridX+1 <= maxX) {
            // right
            let rightCoord = Coordinate(x: gridX+1, y: gridY)
            array.append(rightCoord)
        }
        if (gridY-1 >= minY) {
            // bottom
            let bottomCoord = Coordinate(x: gridX, y: gridY-1)
            array.append(bottomCoord)
        }
        
        if (enableDiagonal) {
            if (gridX-1 >= minX && gridY+1 <= maxY) {
                // left top
                let leftTopCoord = Coordinate(x: gridX-1, y: gridY+1)
                array.append(leftTopCoord)
            }
            if (gridY+1 <= maxY && gridX+1 <= maxX) {
                // right top
                let rightTopCoord = Coordinate(x: gridX+1, y: gridY+1)
                array.append(rightTopCoord)
            }
            if (gridX+1 <= maxX && gridY-1 >= minY) {
                // right bottom
                let rightBottomCoord = Coordinate(x: gridX+1, y: gridY-1)
                array.append(rightBottomCoord)
            }
            if (gridY-1 >= minY && gridX-1 >= minX) {
                // left bottom
                let leftBottomCoord = Coordinate(x: gridX-1, y: gridY-1)
                array.append(leftBottomCoord)
            }
        }
        
        return array
    }
    
}
