//
//  Rule.swift
//  Timecode
//
//  Created by Matthew Gray on 9/22/16.
//  Copyright © 2016 Matthew Gray. All rights reserved.
//

import Foundation

@objc(Rule)
class Rule : NSObject, NSCoding {
    let label: String
    let before: Int
    let length: Int
    let pause: Int
    let repetitions: Int
    
    required init(label:String, before:Int, length:Int, pause:Int, repetitions:Int) {
        self.label = label
        self.before = before
        self.length = length
        self.pause = pause
        self.repetitions = repetitions
        super.init()
    }
    
    static func == (left: Rule, right: Rule) -> Bool {
        return left.label == right.label && left.before == right.before && left.length == right.length && left.pause == right.pause && left.repetitions == right.repetitions
    }

    
    func calculateTotalTime() -> Int {
        return (before + length + pause) * repetitions
    }
    
    override var description: String {
        return label
    }
    
    //MARK: - NSCoding -
    required init(coder aDecoder: NSCoder) {
        label = aDecoder.decodeObject(forKey: "label") as! String
        before = Int(aDecoder.decodeInt32(forKey: "before"))
        length = Int(aDecoder.decodeInt32(forKey: "length"))
        pause = Int(aDecoder.decodeInt32(forKey: "pause"))
        repetitions = Int(aDecoder.decodeInt32(forKey: "repetitions"))
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(label, forKey: "label")
        aCoder.encode(before, forKey: "before")
        aCoder.encode(length, forKey: "length")
        aCoder.encode(pause, forKey: "pause")
        aCoder.encode(repetitions, forKey: "repetitions")
    }
    
    func getCacheName() -> String {
        return "CACHE_" + self.label
    }
}
