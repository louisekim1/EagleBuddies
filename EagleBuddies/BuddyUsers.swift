//
//  BuddyUsers.swift
//  EagleBuddies
//
//  Created by Louise Kim on 5/3/21.
//

import Foundation
import Firebase

class BuddyUsers {
    var userArray: [BuddyUser] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () ->  ()) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
            return completed()
            }
            self.userArray = [] // clean out existing buddyArray since new data will load
            // there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                // You'll have to make sure you have a dictionary initializer in the singular class
                let buddyUser = BuddyUser(dictionary: document.data())
                buddyUser.documentID = document.documentID
                self.userArray.append(buddyUser)
            }
            completed()
        }
    }
}
