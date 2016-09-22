//
//  ViewController.swift
//  Timecode
//
//  Created by Matthew Gray on 9/20/16.
//  Copyright © 2016 Matthew Gray. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    var enabled = false
    var timer = NSTimer()
    var counter = 0
    var pauseClear = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.enabled = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        stopTouched("")
    }
    
    @IBAction func dragged(sender: AnyObject) {
        timeLabel.text = "test"
    }

    @IBAction func startTouched(sender: AnyObject) {
        if pauseClear {
            pauseClear = false;
            stopButton.setTitle("Pause", forState: UIControlState.Normal)
        }
        startButton.enabled = false
        stopButton.enabled = true;
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }
    
    @IBAction func stopTouched(sender: AnyObject) {
        if !pauseClear {
            startButton.enabled = true;
            timer.invalidate()
            pauseClear = true;
            stopButton.setTitle("Clear", forState: UIControlState.Normal)
        } else {
            stopButton.enabled = false;
            pauseClear = false;
            counter = 0;
            timeLabel.text = "00:00:00:0";
            stopButton.setTitle("Pause", forState: UIControlState.Normal)
        }
    }
    
    func update() {
        counter += 1
        let sec = counter / 10
        timeLabel.text = String.init(format: "%02d:%02d:%02d:%d", sec / 3600, (sec / 60) % 3600, sec % 60, counter % 10)
        
        //logic for timing here
    }
    
}

