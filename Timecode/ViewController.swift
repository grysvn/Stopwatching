//
//  ViewController.swift
//  Timecode
//
//  Created by Matthew Gray on 9/20/16.
//  Copyright © 2016 Matthew Gray. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DataEnteredDelegate {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    var enabled = false
    var timer = Timer()
    var counter = 0
    var pauseClear = false;
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addRule" {
            let newRuleView = segue.destination as! NewRuleViewController
            newRuleView.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.isEnabled = false
        self.navigationController?.navigationBar.isTranslucent = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        stopTouched("" as AnyObject)
    }

    //
    //starts the timer
    //
    @IBAction func startTouched(_ sender: AnyObject) {
        if pauseClear {
            pauseClear = false;
            stopButton.setTitle("Pause", for: UIControlState())
        }
        startButton.isEnabled = false
        stopButton.isEnabled = true;
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }
    
    //
    //stops the timer
    //
    @IBAction func stopTouched(_ sender: AnyObject) {
        if !pauseClear {
            startButton.isEnabled = true;
            timer.invalidate()
            pauseClear = true;
            stopButton.setTitle("Clear", for: UIControlState())
        } else {
            stopButton.isEnabled = false;
            pauseClear = false;
            counter = 0;
            timeLabel.text = "00:00:00:0";
            stopButton.setTitle("Pause", for: UIControlState())
        }
    }
    
    //
    //updates the timer
    //
    func update() {
        counter += 1
        let sec = counter / 10
        timeLabel.text = String.init(format: "%02d:%02d:%02d:%d", sec / 3600, (sec / 60) % 3600, sec % 60, counter % 10)
        
        //logic for timing here
    }
    
    //
    //adds a rule to the list
    //
    func addRule(label: String, before: Int, length: Int, pause: Int, reps: Int) {
        timeLabel.text = "test"
    }
    
}

