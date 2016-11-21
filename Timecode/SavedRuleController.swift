//
//  InfoController.swift
//  Timecode
//
//  Created by Matthew Gray on 11/15/16.
//  Copyright © 2016 Matthew Gray. All rights reserved.
//

import Foundation
import UIKit

class SavedRuleController: UITableViewController {
    
    var ruleListList: [RuleList] = [] //list of rule lists, loaded from user defaults
    var names: [String] = [] //list of names of these lists, dictionary made some operations too complicated
    weak var delegate: DataEnteredDelegate? = nil //how we interface with the original view
    
    override func viewDidLoad() {
        //lets load all the keys stored in ns user defaults
        
        for x in UserDefaults.standard.dictionaryRepresentation() {
            if let unarchivedObject = UserDefaults.standard.object(forKey: x.key) as? Data {
                let unarchived = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject)
                if (unarchived is RuleList) {
                    let cast = (unarchived as! RuleList);
                    ruleListList.append(cast);
                    names.append(x.key);
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    //table view shit
    //
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ruleListList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 14.0)
        cell.textLabel?.text = self.names[indexPath.row]
        
        return cell
    }
    
    //
    //item selected
    //
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //set the ruleList in the main screen equal to this
        //Dialog with one input textField & two buttons
        let alert=UIAlertController(title: "Warning!", message: "Tap yes if you want to load this ruleset, it will clear all rules currently in use.  Save them if you don't want to lose them.", preferredStyle: UIAlertControllerStyle.alert);
        //no event handler (just close dialog box)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil));
        //event handler with closure
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            self.delegate?.setNewRuleList(list: self.ruleListList[indexPath.row])
            self.navigationController?.popViewController(animated: true)
        }));
        present(alert, animated: true, completion: nil);
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //
    //item deleted
    //
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ruleListList.remove(at: indexPath.row)
            UserDefaults.standard.removeObject(forKey: names[indexPath.row]);
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}
