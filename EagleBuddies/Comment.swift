//
//  Comment.swift
//  EagleBuddies
//
//  Created by Louise Kim on 5/12/21.
//

import Foundation
import Firebase

class Comment {
    var commentTitle: String
    var comment: String
    var wantToConnect: String
    var socialMediaHandle: String
    var reviewUserID: String
    var reviewUserEmail: String
    var documentID: String
    
    var dictionary:  [String: Any] {
        return ["commentTitle": commentTitle, "comment": comment, "wantToConnect": wantToConnect, "socialMediaHandle": socialMediaHandle, "reviewUserID": reviewUserID, "reviewUserEmail": reviewUserEmail]
    }
    
    init(commentTitle: String, comment: String, wantToConnect: String, socialMediaHandle: String, reviewUserID: String, reviewUserEmail: String, documentID: String) {
        self.commentTitle = commentTitle
        self.comment = comment
        self.wantToConnect = wantToConnect
        self.socialMediaHandle = socialMediaHandle
        self.reviewUserID = reviewUserID
        self.reviewUserEmail = reviewUserEmail
        self.documentID = documentID
    }
    
    convenience init() {
        let reviewUserID = Auth.auth().currentUser?.uid ?? ""
        let reviewUserEmail = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(commentTitle: "", comment: "", wantToConnect: "", socialMediaHandle: "", reviewUserID: reviewUserID, reviewUserEmail: reviewUserEmail, documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let commentTitle = dictionary["commentTitle"] as! String? ?? ""
        let comment = dictionary["comment"] as! String? ?? ""
        let wantToConnect = dictionary["wantToConnect"] as! String? ?? ""
        let socialMediaHandle = dictionary["socialMediaHandle"] as! String? ?? ""
        let reviewUserID = dictionary["reviewUserID"] as! String? ?? ""
        let reviewUserEmail = dictionary["reviewUserEmail"] as! String? ?? ""
        let documentID = dictionary["documentID"] as! String? ?? ""
        
        self.init(commentTitle: commentTitle, comment: comment, wantToConnect: wantToConnect, socialMediaHandle: socialMediaHandle, reviewUserID: reviewUserID, reviewUserEmail: reviewUserEmail, documentID: documentID)
    }
    
    func saveData(buddy: Buddy, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we HAVE saved a record, we'll have  an ID, otherwise  .addDocument will create one.
        if self.documentID == "" { // Create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will create a new ID for us
            ref = db.collection("buddies").document(buddy.documentID).collection("comments").addDocument(data: dataToSave){ (error) in
                guard error == nil else {
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                completion(true)
            }
        } else { // else save to the existing documentID w/ .setData
            let ref = db.collection("buddies").document(buddy.documentID).collection("comment").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                completion(true)
            }
        }
    }
    
    func deleteData(buddy: Buddy, completion: @escaping(Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("buddies").document(buddy.documentID).collection("reviews").document(documentID).delete { (error) in
            if let error = error {
                print("ERROR: deleting review documentID \(self.documentID). Error: \(error.localizedDescription)")
                completion(false)
            }
            completion(true)
        }
    }
}
