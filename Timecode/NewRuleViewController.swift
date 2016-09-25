//
//  NewRuleViewController.swift
//  Timecode
//
//  Created by Matthew Gray on 9/24/16.
//  Copyright © 2016 Matthew Gray. All rights reserved.
//

import UIKit

protocol DataEnteredDelegate: class {
    func addRule(label: String, before: Int, length: Int, pause: Int, reps: Int)
}

class NewRuleViewController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var before: UITextField!
    @IBOutlet weak var length: UITextField!
    @IBOutlet weak var pause: UITextField!
    @IBOutlet weak var reps: UITextField!
    weak var delegate: DataEnteredDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: AnyObject) {
        delegate?.addRule(label: name.text!, before: Int(before.text!)!, length: Int(length.text!)!, pause: Int(pause.text!)!, reps: Int(reps.text!)!)
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
