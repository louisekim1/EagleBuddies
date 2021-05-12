//
//  NewBuddyViewController.swift
//  EagleBuddy
//
//  Created by Louise Kim on 5/10/21.
//

import UIKit

class NewBuddyViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var gradeTextField: UITextField!
    @IBOutlet weak var memberNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var buddy: Buddy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if buddy == nil {
            buddy = Buddy()
        }
    }
    
    func updateUserInterface() {
        nameTextField.text = buddy.name
        gradeTextField.text = buddy.grade
        memberNameTextField.text = buddy.members
        descriptionTextField.text = buddy.description
    }
    
    func updateFromInterface() {
        buddy.name = nameTextField.text ?? ""
        buddy.grade = gradeTextField.text ?? ""
        buddy.members = memberNameTextField.text ?? ""
        buddy.description = descriptionTextField.text ?? ""
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromInterface()
        buddy.saveData { (success) in
            if success {
                self.leaveViewController()
            } else {
                // ERROR during save occured
                self.oneButtonAlert(title: "😡 Save Failed", message: "For some reason, the data would not save to the cloud.")
            }
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
}
