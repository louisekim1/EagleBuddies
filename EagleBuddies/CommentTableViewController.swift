//
//  CommentTableViewController.swift
//  EagleBuddies
//
//  Created by Louise Kim on 5/12/21.
//

import UIKit

class CommentTableViewController: UITableViewController {
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var commentTitleField: UITextField!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var wantToConnectField: UITextField!
    @IBOutlet weak var socialMediaField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    
    var comment: Comment!
    var buddy: Buddy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide keyboard if we tap outside of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        guard buddy != nil else {
            print("ERROR: No spot passed to CommentTableVIewController.swift")
            return
        }
        if comment == nil {
            comment = Comment()
        }
        updateUserInterface()
    }
    
    func updateUserInterface() {
        commentTitleField.text = comment.commentTitle
        commentField.text = comment.comment
        wantToConnectField.text = comment.wantToConnect
        socialMediaField.text = comment.socialMediaHandle
    }
    
    func updateFromUserInterface() {
        comment.commentTitle = commentTitleField.text!
        comment.comment = commentField.text!
        comment.wantToConnect = wantToConnectField.text!
        comment.socialMediaHandle = socialMediaField.text!
    }
    
    func leaveViewController() {
        let isPresentinginAddMode = presentingViewController is UINavigationController
        if isPresentinginAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func commentTitleChanged(_ sender: UITextField) {
        let noSpaces = commentTitleField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if noSpaces != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    @IBAction func commentTitleDonePressed(_ sender: UITextField) {
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        comment.deleteData(buddy: buddy) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("Delete unsuccessful")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        updateFromUserInterface()
        buddy.saveData(buddy: buddy) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("ERROR")
            }
        }
    }
}
