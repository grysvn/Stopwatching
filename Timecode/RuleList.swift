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
    //gets the current rule string (for subheading)
    //
    func getCurrentRuleString(timeStamp: Int) -> String?
    {
        let priorTime = getPriorElapsedTime(timeStamp: timeStamp)
        var time = timeStamp - priorTime //time elapsed under current rule
        let ruleFound = getCurrentRule(timeStamp: timeStamp)
        if (ruleFound == nil) {
            return nil
        }
        let singleRepTime = ruleFound!.calculateTotalTime() / ruleFound!.repetitions
        let repetition = time / singleRepTime + 1
        time = time % singleRepTime
        time -= ruleFound!.before
        if time < 0 {
            let sec = priorTime + (singleRepTime * (repetition - 1)) + ruleFound!.before
            let formattedStamp = String.init(format: "%02d:%02d:%02d:0", sec / 3600, (sec / 60) % 3600, sec % 60)
            return "Countdown \(repetition)/\(ruleFound!.repetitions) done at \(formattedStamp)"
        }
        time -= ruleFound!.length
        if time < 0 {
            let sec = priorTime + (singleRepTime * (repetition - 1)) + ruleFound!.before + ruleFound!.length
            let formattedStamp = String.init(format: "%02d:%02d:%02d:0", sec / 3600, (sec / 60) % 3600, sec % 60)
            return "Activity \(repetition)/\(ruleFound!.repetitions) done at \(formattedStamp)"
        }
        time -= ruleFound!.pause
        if time < 0 {
            let sec = priorTime + (singleRepTime * (repetition))
            let formattedStamp = String.init(format: "%02d:%02d:%02d:0", sec / 3600, (sec / 60) % 3600, sec % 60)
            return "Break \(repetition)/\(ruleFound!.repetitions) done at \(formattedStamp)"
        }
        return "oops"
        //return "Countdown \(repetition)/\(ruleFound!.repetitions)"
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
