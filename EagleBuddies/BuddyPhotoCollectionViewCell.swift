//
//  BuddyPhotoCollectionViewCell.swift
//  EagleBuddies
//
//  Created by Louise Kim on 5/13/21.
//

import UIKit
import SDWebImage

class BuddyPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    var buddy: Buddy!
    var photo: Photo! {
        didSet {
            photoImageView.image = photo.image
            photo.loadImage(buddy: buddy) { (success) in
                if success  {
                    self.photoImageView.image = self.photo.image
                } else  {
                    print("ERROR")
                }
            }
//            if let url = URL(string: self.photo.photoURL) {
//                self.photoImageView.sd_imageTransition =  .fade
//                self.photoImageView.sd_imageTransition?.duration =  0.2
//                self.photoImageView.sd_setImage(with: url)
//            } else {
//                print("URL didn't work \(self.photo.photoURL)")
//                self.photo.loadImage(buddy: self.buddy) { (success) in
//                    self.photo.saveData(buddy: self.buddy) { (success) in
//                        print("image updated with URL \(self.photo.photoURL)")
//                    }
//                }
//            }
        }
    }
}
