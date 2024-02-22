//
//Rules.swift
//
///
///This class represents preset rules for this game.
///There are 2 rules.  First one is awardToAvatarPartRules, it's a dictionary that tells how much award is needed for an avatar part
///Second rule is taskToAwardRules, it tells how much award is earned to complete a todo based on difficulty level
///
///
import Foundation
import SwiftUI

let lowLevlCoins = 5
let basicLevelCoins = 30
let silverLevelCoins = 100
let goldLevelCoins = 200
let plantinumLevelCoins = 500
let extremelyHighLevelCoins = 10000
let indexes = Array(1...12).map { $0 }

struct Rules {
    private var awardToAvatarPartRules = [AvatarPart: Award]()
    private var taskToAwardRules = [DifficultyLevel: Award]()
    
    init() {
        //all basic avatar part needs basicLevelCoins
        indexes.forEach {num in
            AvatarPartType.allCases.forEach {
                let partName = $0
                if num < 7 {
                    awardToAvatarPartRules[AvatarPart(part: partName, category: .basic, index: num)] = Award(coin:lowLevlCoins)
                }else {
                    awardToAvatarPartRules[AvatarPart(part: partName, category: .basic, index: num)] = Award(coin:basicLevelCoins)
                }
            }
        }
        
        //all animal avatar part needs silverLevelCoins
        indexes.forEach {num in
            AvatarPartType.allCases.forEach {
                let partName = $0
                awardToAvatarPartRules[AvatarPart(part: partName, category: .animal, index: num)] = Award(coin:silverLevelCoins)
            }
        }
        
        //castle avatar part needs silverLevelCoins (1..6) or plantinumLevelCoins (7..12)
        indexes.forEach {num in
            AvatarPartType.allCases.forEach {
                let partName = $0
                if num < 7 {
                    awardToAvatarPartRules[AvatarPart(part: partName, category: .castle, index: num)] = Award(coin:goldLevelCoins)
                }
                else {
                    awardToAvatarPartRules[AvatarPart(part: partName, category: .castle, index: num)] = Award(coin:plantinumLevelCoins)
                }
            }
        }
        
        //fill in taskToAwardRules
        taskToAwardRules[.easy] = Award(coin:1)
        taskToAwardRules[.medium] = Award(coin:3)
        taskToAwardRules[.hard] = Award(coin:5)
    }
    
    
    func printRules() -> Void {
        
        print("taskToAwardRules")
        for (key,value) in taskToAwardRules {
            print("\(key) = \(value)")
        }
        
        print("awardToAvatarPartRules")
        for (key,value) in awardToAvatarPartRules {
            print("\(key) = \(value)")
        }
    }
    
    ///This function tells how much award is earned based on difficulty level of a todo
    ///In Parameter --`taskLevel`: DifficultyLevel can be easy, medium and hard
    ///Return --`Award`: the award earned based on preset rules from the todo
    ///
    func getAward(taskLevel: DifficultyLevel) -> Award {
        guard let _ = taskToAwardRules[taskLevel] else {
            return Award(coin:extremelyHighLevelCoins)
        }
        
        return taskToAwardRules[taskLevel]!
    }
    

    ///This function tells how much award is needed  to purchase an avatar part
    ///In Parameter --`avatarPart`: the avatar part to be purchased
    ///Return --`Award`: the award needed for the part
    ///
    func getAward(avatarPart: AvatarPart) -> Award {
        guard let _ = awardToAvatarPartRules[avatarPart] else {
            return Award(coin:extremelyHighLevelCoins)
        }
        
        return awardToAvatarPartRules[avatarPart]!
    }
}
