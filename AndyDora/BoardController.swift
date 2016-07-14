//
//  BoardController.swift
//  AndyDora
//
//  Created by AU HO CHUN on 7/10/16.
//  Copyright © 2016 fatlungau. All rights reserved.
//

import UIKit

enum BoardType : Int {
    case BoardType5Colors = 5
    case BoardType6Colors = 6
    case BoardTypeAllColors = 9
}

class BoardController: NSObject {

    var boardConfiguration : BoardConfiguration
    var drop2dArray : [[DropData]]?
    
    init (boardConfiguration:BoardConfiguration) {
        
        self.boardConfiguration = boardConfiguration
        super.init()
        self.setupBoardData()
    }
    
    func setupBoardData() {
        
        self.drop2dArray = [[DropData]]()
        let size = boardConfiguration.size
        for i : Int in 0...size.width-1 {
            var columnData = [DropData]()
            for j : Int in 0...size.height-1 {
                let randomNumber : Int = Int(arc4random())
                let modNumber : Int = self.boardConfiguration.boardType.rawValue;
                let dropType = DropType(rawValue:randomNumber%modNumber)
                let dropData = DropData(coord:Coordinate(x:i, y:j),
                    gridColor:UIColor.clearColor(),
                    boardSize:self.boardConfiguration.size,
                    enableDiagonal: true)
                dropData.dropType = dropType
                columnData.append(dropData)
            }
            self.drop2dArray?.append(columnData)
        }
    }
    
    subscript(row: Int, column: Int) -> DropData? {
        
        var dropData : DropData?
        if let dropArray : [[DropData]] = self.drop2dArray {
            if row < dropArray.count {
                let dropRow = dropArray[row] as [DropData]
                if column < dropRow.count {
                    dropData = dropRow[column]
                }
            }
        }
        return dropData
    }
    
    func swapTwoCoordinates(coordinate1:Coordinate, coordinate2:Coordinate) {
    
        let coordinate1Data = self[coordinate1.x, coordinate1.y] as DropData?
        let coordinate2Data = self[coordinate2.x, coordinate2.y] as DropData?
        coordinate2Data?.coordinate = coordinate1
        coordinate1Data?.coordinate = coordinate2
        var coordinate1Column = self.drop2dArray?[coordinate1.x] as [DropData]?
        coordinate1Column?[coordinate1.y] = coordinate2Data!
        self.drop2dArray?[coordinate1.x] = coordinate1Column!
        var coordinate2Column = self.drop2dArray?[coordinate2.x] as [DropData]?
        coordinate2Column?[coordinate2.y] = coordinate1Data!
        self.drop2dArray?[coordinate2.x] = coordinate2Column!

    }
    
    
    func solveBoard() -> [DropType:[BoardSolution]]{
        
        let horizontalSolutions = self.scanForHorizonatal()
        let verticalSolutions = self.scanForVertical()
        let solutionDictionary = self.combinedHorizontalVerticalSolutions(horizontalSolutions, verticalDictionary: verticalSolutions)
        return solutionDictionary
        
    }
    
    func scanForHorizonatal() -> [DropType:[BoardSolution]] {
        
        let dropTypes = DropData.dropTypesForBoardType(self.boardConfiguration.boardType)
        var horizontalDictionary = [DropType:[BoardSolution]]()
        for type : DropType in dropTypes {
            var boardSolutions = [BoardSolution]()
            for i : Int in 0..<self.boardConfiguration.size.height {
                
                var nextIterateIndex = 0
                for j : Int in 0..<self.boardConfiguration.size.width {
                    if j < nextIterateIndex {
                        continue
                    }
                    
                    var iteratingDropData = self[j,i]
                    var dropData = iteratingDropData
                    var count = 0
                    var index = 0
                    while (iteratingDropData?.dropType == type ) {
                        dropData = iteratingDropData!
                        count++
                        if j+count < self.boardConfiguration.size.width {
                            iteratingDropData   = self[j+count,i]
                        } else {
                            break;
                        }
                        index = j+count
                    }
                    nextIterateIndex = index
                    if count >= 3 { // >= 3 is a solution
                        let coordinates = self.coordinatesForConsecutiveDrop(dropData, consecutiveCount: count, isHorizontal: true)
                        var groupingSolutions = [BoardSolution]()
                        for solution : BoardSolution in boardSolutions {
                            // check y difference, if its not on top or below, just move to next solution
                            if coordinates.count > 0 && solution.coordinates.count > 0{
                                let firstNewCoordinate = coordinates[0]
                                let existingCoordinate = solution.coordinates[0]
                                if abs(existingCoordinate.y - firstNewCoordinate.y) > 1  {
                                    continue
                                }
                            }
                            
                            // Check if any overrlapping x value over two rows
                            for existingCoordinate: Coordinate in solution.coordinates {
                                var alreadyGrouped = false
                                for newCoordinate: Coordinate in coordinates {
                                    if abs(existingCoordinate.x - newCoordinate.x) == 0 {
                                        groupingSolutions.append(solution)
                                        alreadyGrouped = true
                                        break;
                                    }
                                }
                                if alreadyGrouped {
                                    break;
                                }
                            }
                            
                        }
                        if groupingSolutions.count > 0 {
                            var groupedCoordinates = [Coordinate]()
                            groupedCoordinates.appendContentsOf(coordinates)
                            for solution : BoardSolution in groupingSolutions {
                                groupedCoordinates.appendContentsOf(solution.coordinates)
                                if let index = boardSolutions.indexOf(solution) {
                                    boardSolutions.removeAtIndex(index)
                                }
                            }
                            boardSolutions.append(BoardSolution(coordinates: groupedCoordinates, dropType: type))
                        } else {
                            // Add solution
                            boardSolutions.append(BoardSolution(coordinates: coordinates, dropType: type))
                        }
                    }
                }
            }
            horizontalDictionary[type] = boardSolutions
        }
        return horizontalDictionary
    }
    
    func scanForVertical() -> [DropType:[BoardSolution]] {
        
        let dropTypes = DropData.dropTypesForBoardType(self.boardConfiguration.boardType)
        var verticalDictionary = [DropType:[BoardSolution]]()
        for type : DropType in dropTypes {
            var boardSolutions = [BoardSolution]()
            for i : Int in 0..<self.boardConfiguration.size.width {
                
                var nextIterateIndex = 0
                for j : Int in 0..<self.boardConfiguration.size.height {
                    if j < nextIterateIndex {
                        continue
                    }
                    
                    var iteratingDropData = self[i,j]
                    var dropData = iteratingDropData
                    var count = 0
                    var index = 0
                    while (iteratingDropData?.dropType == type ) {
                        dropData = iteratingDropData!
                        count++
                        if j+count < self.boardConfiguration.size.height {
                            iteratingDropData   = self[i,j+count]
                        } else {
                            break;
                        }
                        index = j+count
                    }
                    nextIterateIndex = index
                    if count >= 3 { // >= 3 is a solution
                        let coordinates = self.coordinatesForConsecutiveDrop(dropData, consecutiveCount: count, isHorizontal: false)
                        var groupingSolutions = [BoardSolution]()
                        for solution : BoardSolution in boardSolutions {
                            // check x difference, if its not left or right, just move to next solution
                            if coordinates.count > 0 && solution.coordinates.count > 0{
                                let firstNewCoordinate = coordinates[0]
                                let existingCoordinate = solution.coordinates[0]
                                if abs(existingCoordinate.x - firstNewCoordinate.x) > 1  {
                                    continue
                                }
                            }
                            
                            // Check if any overrlapping y value over two rows
                            for existingCoordinate: Coordinate in solution.coordinates {
                                var alreadyGrouped = false
                                for newCoordinate: Coordinate in coordinates {
                                    if abs(existingCoordinate.y - newCoordinate.y) == 0 {
                                        groupingSolutions.append(solution)
                                        alreadyGrouped = true
                                        break;
                                    }
                                }
                                if alreadyGrouped {
                                    break;
                                }
                            }
                            
                        }
                        if groupingSolutions.count > 0 {
                            var groupedCoordinates = [Coordinate]()
                            groupedCoordinates.appendContentsOf(coordinates)
                            for solution : BoardSolution in groupingSolutions {
                                groupedCoordinates.appendContentsOf(solution.coordinates)
                                if let index = boardSolutions.indexOf(solution) {
                                    boardSolutions.removeAtIndex(index)
                                }
                            }
                            boardSolutions.append(BoardSolution(coordinates: groupedCoordinates, dropType: type))
                        } else {
                            // Add solution
                            boardSolutions.append(BoardSolution(coordinates: coordinates, dropType: type))
                        }
                    }
                }
                
            }
            verticalDictionary[type] = boardSolutions
        }
        return verticalDictionary
    }
    
    func combinedHorizontalVerticalSolutions(horizontalDictionary:[DropType:[BoardSolution]], verticalDictionary:[DropType:[BoardSolution]]) -> [DropType:[BoardSolution]] {
        
        var solutionDictionary = [DropType:[BoardSolution]]()
        let dropTypes = DropData.dropTypesForBoardType(self.boardConfiguration.boardType)
        for type : DropType in dropTypes {
            
            let horizontal = horizontalDictionary[type]!
            let vertical = verticalDictionary[type]!
            var combinedBoardSolutions = [BoardSolution]()
            combinedBoardSolutions.appendContentsOf(horizontal)
            combinedBoardSolutions.appendContentsOf(vertical)
            
            for horizontalSolution in horizontal {
                for verticalSolution in vertical {
                    let coords = horizontalSolution.containsSolution(verticalSolution)
                    if (coords.count > 0) {
                        // have same coordinates, grouping it
                        var coordinateArray = [Coordinate]()
                        coordinateArray.appendContentsOf(horizontalSolution.coordinates)
                        for verticalCoordinate in verticalSolution.coordinates {
                            var shouldAdd = true
                            for matchedCoordinates in coords {
                                if matchedCoordinates == verticalCoordinate {
                                    shouldAdd = false
                                }
                            }
                            if shouldAdd {
                                coordinateArray.append(verticalCoordinate)
                            }
                        }
                        
                        let combinedSolution = BoardSolution(coordinates: coordinateArray, dropType: type)
                        // remove the combined solutions
                        if let verticalIndex = combinedBoardSolutions.indexOf(verticalSolution) {
                            combinedBoardSolutions.removeAtIndex(verticalIndex)
                        }
                        if let horizontalIndex = combinedBoardSolutions.indexOf(horizontalSolution) {
                            combinedBoardSolutions.removeAtIndex(horizontalIndex)
                        }
                        
                        combinedBoardSolutions.append(combinedSolution)
                    }
                }
            }
            solutionDictionary[type] = combinedBoardSolutions
        }
        return solutionDictionary
    }

    func coordinatesForConsecutiveDrop(dropData: DropData?, consecutiveCount:Int, isHorizontal:Bool) -> [Coordinate] {
        
        let coordinate = dropData!.coordinate
        var coordinates = [Coordinate]()
        for i : Int in 0..<consecutiveCount {
            if isHorizontal {
                coordinates.append(Coordinate(x: coordinate.x-i, y: coordinate.y))
            } else {
                coordinates.append(Coordinate(x: coordinate.x, y: coordinate.y-i))
            }
        }
        return coordinates
    }
    
    
    func removeSolutionsFromBoard(solutions:[BoardSolution]) {
        
        for solution in solutions {
            for coordinate in solution.coordinates {
                if let drops = self.drop2dArray?[coordinate.x] { //collumn
                    let filteredDrops = drops.filter({ (dropData :DropData) -> Bool in
                        if dropData.coordinate == coordinate {
                            return false
                        } else {
                            return true
                        }
                    })
                    self.drop2dArray?[coordinate.x] = filteredDrops
                }
            }
        }
        
        NSLog("%@", (self.drop2dArray?.description)!)
    }
    
    
    func reassignCoordinateForBoard() {
        
        for i in 0..<self.boardConfiguration.size.width {
            if let drops = self.drop2dArray?[i] {
                for j in 0..<drops.count {
                    drops[j].coordinate = Coordinate(x:i, y:j)
                }
            }
        }
        
    }
}

class BoardSolution : NSObject {
    
    var coordinates : [Coordinate]
    var dropType : DropType
    
    init (coordinates:[Coordinate], dropType:DropType) {
        
        self.coordinates = coordinates
        self.dropType = dropType
        super.init()
    }
    
    func containsSolution(another:BoardSolution) -> [Coordinate] {
        
        var sameCoordinates = [Coordinate]()
        for ownCoordinates in self.coordinates {
            for anotherCoordinates in another.coordinates {
                if ownCoordinates == anotherCoordinates {
                    sameCoordinates.append(anotherCoordinates)
                }
            }
        }
        return sameCoordinates
    }
    
    override var description : String {
        return self.coordinates.description
    }
    
}



class BoardConfiguration : NSObject {
    
    var boardType : BoardType
    var size : Size
    
    init(boardType: BoardType, size:Size) {
        
        self.size = size
        self.boardType = boardType
        super.init()
    }
    
}
