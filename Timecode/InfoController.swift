//
//  InfoController.swift
//  Timecode
//
//  Created by Matthew Gray on 11/15/16.
//  Copyright © 2016 Matthew Gray. All rights reserved.
//

import Foundation
import UIKit

class InfoController: UITableViewController {
    
    @IBOutlet weak var disableSleepingSwitch: UISwitch!
    
    @IBAction func disableSleepingChanged(_ sender: Any) {
        UIApplication.shared.isIdleTimerDisabled = true
        if (disableSleepingSwitch.isOn) {
            UIApplication.shared.isIdleTimerDisabled = true
        } else {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    override func viewDidLoad() {
        //load the setting
        super.viewDidLoad()
        if (UIApplication.shared.isIdleTimerDisabled) {
            disableSleepingSwitch.setOn(true, animated: false)
        } else {
            disableSleepingSwitch.setOn(false, animated: false)
        }
        
    }
    @IBAction func website(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://www.mattgray.net")!)
    }
    
    @IBAction func email(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "mailto:matt@mattgray.net")!)
    }
    
    @IBAction func twitter(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://www.twitter.com/grayma7")!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
