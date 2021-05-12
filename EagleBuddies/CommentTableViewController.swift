//
//  CommentTableViewController.swift
//  EagleBuddies
//
//  Created by Louise Kim on 5/12/21.
//

import UIKit
import Firebase

class CommentTableViewController: UITableViewController {
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var commentTitleField: UITextField!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var wantToConnectField: UITextField!
    @IBOutlet weak var socialMediaField: UITextField!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
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
            print("ERROR: No commet passed to CommentTableVIewController.swift")
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
        if comment.documentID == "" { // this is a new review
            addBordersToEditableObjects()
        } else {
            if comment.reviewUserID == Auth.auth().currentUser?.uid  { // review posted by current user
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBordersToEditableObjects()
                deleteButton.isHidden = false
            } else { // review posted by different user
                saveBarButton.hide()
                cancelBarButton.hide()
                postedByLabel.text = "Posted by: \(comment.reviewUserEmail)"
            }
            commentTitleField.isEnabled = false
            commentTitleField.borderStyle = .none
            commentTitleField.isEnabled = false
            wantToConnectField.isEnabled = false
            socialMediaField.isEnabled = false
            commentTitleField.backgroundColor = .white
            commentField.backgroundColor = .white
        }
    }
    
    func updateFromUserInterface() {
        comment.commentTitle = commentTitleField.text!
        comment.comment = commentField.text!
        comment.wantToConnect = wantToConnectField.text!
        comment.socialMediaHandle = socialMediaField.text!
    }
    
    func addBordersToEditableObjects() {
        commentTitleField.addBorder(width: 0.5, radius: 5.0, color: .black)
        commentField.addBorder(width: 0.5, radius: 5.0, color: .black)
        wantToConnectField.addBorder(width: 0.5, radius: 5.0, color: .black)
        socialMediaField.addBorder(width: 0.5, radius: 5.0, color: .black)
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
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        comment.saveData(buddy: buddy) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("ERROR")
            }
        }
    }
}

