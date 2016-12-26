//
//  ViewController.swift
//  Timecode
//
//  Created by Matthew Gray on 9/20/16.
//  Copyright © 2016 Matthew Gray. All rights reserved.
//

import AVFoundation //for sound

import UIKit

class ViewController: UIViewController, DataEnteredDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var ruleTable: UITableView!
    var ruleList = RuleList(List: [Rule]())
    //var ruleKeys: [String] = []
    //var enabled = false //wh
    var editingRule = false //editing a rule
    var timer = Timer() //timer for timing. duh
    var counter = 0 //timer 10th of a second counter used for timing
    var pauseClear = false //used for keeping track of whether pause should be "Pause" or "Clear"
    var selectionIsFromUser = true //used for whether we should ignore a selection, or allow user to edit rule
    var changed = false //whether or not a change has been made and if the rule set should be saved or not
    var startTimeStamp = NSDate.distantPast //time stamp the timer started at
    
    let COUNTDOWN: SystemSoundID = SystemSoundID(1106)
    let START: SystemSoundID = SystemSoundID(1005)
    let END: SystemSoundID = SystemSoundID(1005)
    
    //UserDefaults keys
    let RUNNING = "running" //for boolean running value
    let TIMESTAMP = "timestamp" //for timestamp started at
    let ELAPSED = "elapsed"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addRule" && self.editingRule {
            if let addRule = segue.destination as? NewRuleViewController {
                let rule = (sender! as! Rule)
                addRule.delegate = self
                addRule.rule = rule
                addRule.editingRule = true
                addRule.index = ruleList.List.index(of: rule)!
                self.editingRule = false
            }
        }
        else if segue.identifier == "addRule" {
            let newRuleView = segue.destination as! NewRuleViewController
            newRuleView.delegate = self
        }
        else if segue.identifier == "showSavedRules" {
            if let savedRules = segue.destination as? SavedRuleController {
                savedRules.delegate = self
            }
        }
    }
    
    //load the timer
    func loadTimer()
    {
        //check if we need to set the timer
        if let stamp = UserDefaults.standard.object(forKey: TIMESTAMP) as? Date {
            if stamp != Date.distantPast { //it was running
                startTimeStamp = stamp
                let secsSince = Date().timeIntervalSince(startTimeStamp)
                counter = Int(secsSince) * 10
                
                //for elapsed time
                if (UserDefaults.standard.object(forKey: ELAPSED) != nil) {
                    counter += UserDefaults.standard.integer(forKey: ELAPSED)
                }
                UserDefaults.standard.set(counter, forKey: ELAPSED)
                let sec = counter / 10
                timeLabel.text = String.init(format: "%02d:%02d:%02d:%d", sec / 3600, (sec / 60) % 3600, sec % 60, counter % 10)
                
                //now whether or not we're running
                let running = UserDefaults.standard.bool(forKey: RUNNING)
                if running {
                    startTouched(self);
                } /*else { //don't think this will ever run but here just in case
                 stopButton.setTitle("Clear", for: UIControlState())
                 stopButton.isEnabled = true;
                 pauseClear = true;
                 } */ //removed because it was mistakenly clearing the application
            } else { //when paused or not run
                if (UserDefaults.standard.object(forKey: ELAPSED) != nil) {
                    counter = UserDefaults.standard.integer(forKey: ELAPSED)
                    if (counter != 0) {
                        let sec = counter / 10
                        timeLabel.text = String.init(format: "%02d:%02d:%02d:%d", sec / 3600, (sec / 60) % 3600, sec % 60, counter % 10)
                        stopButton.setTitle("Clear", for: UIControlState())
                        stopButton.isEnabled = true;
                    }
                    pauseClear = true;
                }
            }
        }
    }
    
    func viewResumed()
    {
        loadTimer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.isEnabled = false
        self.navigationController?.navigationBar.isTranslucent = false
        UIApplication.shared.isIdleTimerDisabled = true
        self.ruleTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //resuming from backgrounding
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewResumed), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        //load it here and on view resumed because the events are mutually exclusive
        loadTimer()
        
        //lets add any rules that are saved
        for x in UserDefaults.standard.dictionaryRepresentation() {
            if let unarchivedObject = UserDefaults.standard.object(forKey: x.key) as? Data {
                let unarchived = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject)
                if (unarchived is Rule) {
                    let cast = (unarchived as! Rule);
                    ruleList.List.append(cast);
                    //ruleKeys.append(x.key);
                }
            }
        }
        ruleTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        stopTouched("" as AnyObject)
    }
    
    @IBAction func showInfoPane(_ sender: Any) {
        //performSegue(withIdentifier: "showInfo", sender: sender)
    
    }

    //
    //starts the timer
    //
    @IBAction func startTouched(_ sender: AnyObject) {
        if pauseClear {
            pauseClear = false;
            stopButton.setTitle("Pause", for: UIControlState())
        }
        //we run this not just on start, because we need to keep track of elapsed time with pauses
        startTimeStamp = Date()
        UserDefaults.standard.set(startTimeStamp, forKey: TIMESTAMP)
        
        UserDefaults.standard.set(true, forKey: RUNNING)
        startButton.isEnabled = false
        stopButton.isEnabled = true;
        if (!timer.isValid) {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        }
        selectionIsFromUser = false
        ruleTable.isUserInteractionEnabled = false
    }
    
    //
    //stops the timer
    //
    @IBAction func stopTouched(_ sender: AnyObject) {
        UserDefaults.standard.set(false, forKey: RUNNING) //if app is unloaded and reloaded, we want to have the timer STOPPED
        if !pauseClear {
            startButton.isEnabled = true;
            timer.invalidate()
            pauseClear = true;
            stopButton.setTitle("Clear", for: UIControlState())
            
            //we do this to prevent the backgrounding timestamp from advancing even when the timer is paused
            UserDefaults.standard.set(counter, forKey: ELAPSED)
            UserDefaults.standard.set(false, forKey: RUNNING)
            startTimeStamp = Date.distantPast
            UserDefaults.standard.set(startTimeStamp, forKey: TIMESTAMP)
        } else {
            stopButton.isEnabled = false;
            pauseClear = false;
            counter = 0;
            timeLabel.text = "00:00:00:0";
            
            //backgrounding stuff
            startTimeStamp = Date.distantPast
            UserDefaults.standard.set(0, forKey: ELAPSED)
            UserDefaults.standard.set(startTimeStamp, forKey: TIMESTAMP)
            
            stopButton.setTitle("Pause", for: UIControlState())
            if ((self.ruleTable.indexPathForSelectedRow) != nil) {
                self.ruleTable.cellForRow(at: self.ruleTable.indexPathForSelectedRow!)!.detailTextLabel?.text = ""
                self.ruleTable.deselectRow(at: self.ruleTable.indexPathForSelectedRow!, animated: true)
            }
            ruleTable.isUserInteractionEnabled = true
            selectionIsFromUser = true
        }
    }
    
    //
    //updates the timer
    //
    func update() {
        let sec = counter / 10
        timeLabel.text = String.init(format: "%02d:%02d:%02d:%d", sec / 3600, (sec / 60) % 3600, sec % 60, counter % 10)
        //logic for timing here
        
        let current = ruleList.getCurrentRule(timeStamp: sec)
        if ((current) != nil) {
            let ind = ruleList.List.index(of: current!)
            let path = IndexPath(row: ind!, section: 0)
            var prevPath: IndexPath?
            if (ind! != 0) {
                prevPath = IndexPath(row: ind! - 1, section: 0)
            }
            if (prevPath != nil) {
                self.ruleTable.cellForRow(at: prevPath!)?.detailTextLabel?.text = ""
            }
            self.ruleTable.selectRow(at: path, animated: true, scrollPosition: UITableViewScrollPosition.middle)
            self.ruleTable.cellForRow(at: path)?.detailTextLabel?.text = ruleList.getCurrentRuleString(timeStamp: sec)
            //self.ruleTable.cellForRow(at: path)?.detailTextLabel?.text = "test"
            if (counter % 10 == 0) {
                let elapsed = ruleList.getPriorElapsedTime(timeStamp: sec)
                if (counter == 0 || (sec - elapsed) % (current!.before + current!.length + current!.pause) < current!.before) { //COUNTDOWN
                    AudioServicesPlaySystemSound(COUNTDOWN)
                } else if ((sec - elapsed) % (current!.before + current!.length + current!.pause) == current!.before ) { //START
                    AudioServicesPlaySystemSound(START)
                } else if ((sec - elapsed) % (current!.before + current!.length + current!.pause) == current!.before + current!.length) {
                    AudioServicesPlaySystemSound(END)
                }
                //end
            }
        } else {
            if ((self.ruleTable.indexPathForSelectedRow) != nil) {
                self.ruleTable.cellForRow(at: self.ruleTable.indexPathForSelectedRow!)!.detailTextLabel?.text = ""
                self.ruleTable.deselectRow(at: self.ruleTable.indexPathForSelectedRow!, animated: true)
            }
        }
        counter += 1
    }
    
    //
    //adds a rule to the list
    //
    func addRule(label: String, before: Int, length: Int, pause: Int, reps: Int) {
        let rule = Rule(label: label, before: before, length: length, pause: pause, repetitions: reps)
        //ruleTable.beginUpdates()
        ruleList.List.append(rule)
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: rule), forKey: rule.getCacheName())
        ruleTable.reloadData()
        //ruleTable.endUpdates()
        changed = true
    }
    
    //
    //edits a rule in the list
    //
    func editRule(index: Int, label: String, before: Int, length: Int, pause: Int, reps: Int) {
        let rule = Rule(label: label, before: before, length: length, pause: pause, repetitions: reps)
        //ruleTable.beginUpdates()
        ruleList.List.remove(at: index)
        UserDefaults.standard.removeObject(forKey: rule.getCacheName()); //also remove it from cache
        ruleList.List.insert(rule, at: index)
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: rule), forKey: rule.getCacheName())
        ruleTable.reloadData()
        //ruleTable.endUpdates()
        changed = true
    }
    
    //
    //resets the rulelist to a new list
    //
    func setNewRuleList(list: RuleList) {
        ruleList = list
        
        for x in UserDefaults.standard.dictionaryRepresentation() {
            if let unarchivedObject = UserDefaults.standard.object(forKey: x.key) as? Data {
                let unarchived = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject)
                if (unarchived is Rule) {
                    let rule = (unarchived as! Rule);
                    UserDefaults.standard.removeObject(forKey: rule.getCacheName()); //also remove it from cache
                    //ruleKeys.append(x.key);
                }
            }
        }
        
        for rule in ruleList.List {
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: rule), forKey: rule.getCacheName())
        }
        
        ruleTable.reloadData()
        changed = false
    }
    
    
    @IBAction func saveRuleSet(_ sender: Any) {
        
        //http://stackoverflow.com/questions/26567413/get-input-value-from-textfield-in-ios-alert-in-swift
        if (!changed) {
            return
        }
        //thanks SO!
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Enter a saving title:", message: "Rule list title:", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: self.ruleList), forKey: textField.text!)
            self.changed = false
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //
    //table view shit
    //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ruleList.List.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell:UITableViewCell = self.ruleTable.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 14.0)
        cell.textLabel?.text = self.ruleList.List[indexPath.row].label
        
        return cell
    }
    
    //
    //item selected
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectionIsFromUser {
            self.editingRule = true
            performSegue(withIdentifier: "addRule", sender: ruleList.List[indexPath.row])
        } else {
            return //ignore
        }
    }

    //
    //item deleted
    //
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let rule = ruleList.List.remove(at: indexPath.row)
            UserDefaults.standard.removeObject(forKey: rule.getCacheName()); //also remove it from cache
            tableView.deleteRows(at: [indexPath], with: .fade)
            if ruleList.List.count == 0 {
                changed = false
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

