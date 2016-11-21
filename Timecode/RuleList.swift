//
//  RuleList.swift
//  Timecode
//
//  Created by Matthew Gray on 9/22/16.
//  Copyright © 2016 Matthew Gray. All rights reserved.
//

import Foundation

@objc(RuleList)
class RuleList : NSObject, NSCoding {
    var List: [Rule]
    
    required init(List: [Rule]) {
        self.List = List
        super.init()
    }
    
    //MARK: - NSCoding -
    required init(coder aDecoder: NSCoder) {
        List = aDecoder.decodeObject(forKey: "List") as! [Rule]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(List, forKey: "List")
    }

    
    //
    //gets elapsed seconds before current rule
    //
    func getPriorElapsedTime(timeStamp: Int) -> Int {
        var elapsed = 0
        for rule in List {
            let ruleTime = rule.calculateTotalTime()
            if elapsed + ruleTime > timeStamp {
                return elapsed
            }
            elapsed += ruleTime
        }
        return elapsed
    }
    
    //
    //gets the current rule via timestamp (in seconds)
    //
    func getCurrentRule(timeStamp: Int) -> Rule?
    {
        var time = 0
        for rule in List {
            time += rule.calculateTotalTime()
            if timeStamp < time {
                return rule
            }
        }
        return nil
    }
    
    //
    //gets the next rule from the current time stamp
    //
    func getNextRule(timeStamp: Int) -> Rule? {
        var time = 0
        for rule in List {
            if timeStamp < time {
                return rule
            }
            time += rule.calculateTotalTime()
        }
        return nil
    }
}
