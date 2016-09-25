//
//  Rule.swift
//  Timecode
//
//  Created by Matthew Gray on 9/22/16.
//  Copyright © 2016 Matthew Gray. All rights reserved.
//

import Foundation

class Rule {
    var label = ""
    var before = 0
    var length = 0
    var pause = 0
    var repetitions = 0
    
    init (label: String, before: Int, length: Int, pause: Int, repetitions: Int) {
        self.label = label;
        self.before = before;
        self.length = length;
        self.pause = pause;
        self.repetitions = repetitions;
    }
    
    func calculateTotalTime() {
        
    }
}