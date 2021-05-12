//
//  BuddyDetailViewController.swift
//  EagleBuddy
//
//  Created by Louise Kim on 5/10/21.
//

import UIKit

class BuddyDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var memberTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    var buddy: Buddy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if buddy == nil {
            buddy = Buddy()
        }
    }
    
    func updateUserInterface() {
        nameTextField.text = buddy.name
        yearTextField.text = buddy.grade
        memberTextField.text = buddy.members
        descriptionTextView.text = buddy.description
    }
    
    func updateFromInterface() {
        buddy.name = nameTextField.text ?? ""
        buddy.grade = yearTextField.text ?? ""
        buddy.members = memberTextField.text ?? ""
        buddy.description = descriptionTextView.text ?? ""
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
        let isPresentinginAddMode = presentingViewController is UINavigationController
        if isPresentinginAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
