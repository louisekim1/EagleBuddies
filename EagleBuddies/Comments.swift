//
//  Comments.swift
//  EagleBuddies
//
//  Created by Louise Kim on 5/12/21.
//

import Foundation
import Firebase

class Comments {
    var commentArray: [Comment] = []
    
    var db: Firestore!
    
    init()  {
        db = Firestore.firestore()
    }
    
    func loadData(buddy: Buddy, completed: @escaping () ->  ()) {
        guard buddy.documentID != "" else {
            return
        }
        db.collection("buddies").document(buddy.documentID).collection("comments").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
            return completed()
            }
            self.commentArray = [] // clean out existing spotArray since new data will load
            // there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                // You'll have to make sure you have a dictionary initializer in the singular class
                let comment = Comment(dictionary: document.data())
                comment.documentID = document.documentID
                self.commentArray.append(comment)
            }
            completed()
        }
    }
    
}

