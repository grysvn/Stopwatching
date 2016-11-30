//
//  NewRuleViewController.swift
//  Timecode
//
//  Created by Matthew Gray on 9/24/16.
//  Copyright © 2016 Matthew Gray. All rights reserved.
//

import UIKit

protocol DataEnteredDelegate: class {
    func addRule(label: String, before: Int, length: Int, pause: Int, reps: Int) //used when adding a rule
    func editRule(index: Int, label: String, before: Int, length: Int, pause: Int, reps: Int) //used when editing a rule
    func setNewRuleList(list: RuleList) //used when resetting the current RuleList to a new/old RuleList
}

class NewRuleViewController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var before: UITextField!
    @IBOutlet weak var length: UITextField!
    @IBOutlet weak var pause: UITextField!
    @IBOutlet weak var reps: UITextField!
    weak var delegate: DataEnteredDelegate? = nil
    
    var rule: Rule?
    var editingRule = false
    var index = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if editingRule {
            name.text = rule?.label
            before.text = "\(rule!.before)"
            length.text = "\(rule!.length)"
            pause.text = "\(rule!.pause)"
            reps.text = "\(rule!.repetitions)"
            self.navigationItem.title = "Edit Rule"
        } else {
            self.navigationItem.title = "New Rule"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: AnyObject) {
        if ((name.text?.isEmpty)! || (before.text?.isEmpty)! || (length.text?.isEmpty)! || (pause.text?.isEmpty)! || (reps.text?.isEmpty)! || Int(pause.text!)! < 3) {
            /*let alert = UIAlertView()
            alert.title = "Error!"
            alert.message = "You cannot add a rule with any empty fields."
            alert.addButton(withTitle: "Got it!")
            alert.show()
            return*/
            
            //thanks SO!
            //1. Create the alert controller.
            var alert: UIAlertController
            if (pause.text?.isEmpty)! == false && Int(pause.text!)! < 3 {
                alert = UIAlertController(title: "Error!", message: "You cannot add a rule with a break less than 3 seconds", preferredStyle: .alert)
            } else {
                alert = UIAlertController(title: "Error!", message: "You cannot add a rule with any empty fields", preferredStyle: .alert)
            }
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "Got it!", style: .default))
            
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
            
            return

        }
        let nameText = name.text!
        let beforeNum = Int(before.text!)!
        let lengthNum = Int(length.text!)!
        let pauseNum = Int(pause.text!)!
        let repsNum = Int(reps.text!)!
        if (editingRule) {
            editingRule = false;
            delegate?.editRule(index: index, label: nameText, before: beforeNum, length: lengthNum, pause: pauseNum, reps: repsNum)
        } else {
            delegate?.addRule(label: nameText, before: beforeNum, length: lengthNum, pause: pauseNum, reps: repsNum)
        }
        clearFields()
        self.navigationController?.popViewController(animated: true)
    }
    
    func clearFields() {
        name.text = ""
        before.text = ""
        length.text = ""
        pause.text = ""
        reps.text = ""
    }

}
