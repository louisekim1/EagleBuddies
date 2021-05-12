//
//  UIBarButtonItem+hide.swift
//  Snacktacular
//
//  Created by Louise Kim on 4/24/21.
//

import UIKit

extension UIBarButtonItem {
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}
