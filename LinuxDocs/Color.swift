//
//  Color.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 8/21/17.
//  Copyright © 2017 Praveen Gowda I V. All rights reserved.
//

import Foundation
import UIKit

enum Color {
    static func Section(value: Int) -> UIColor {
        switch value {
            case 0:
                return UIColor(red:0.95, green:0.26, blue:0.21, alpha:1)
            case 1:
                return UIColor(red:0.25, green:0.32, blue:0.71, alpha:1)
            case 2:
                return UIColor(red:0.29, green:0.68, blue:0.31, alpha:1)
            case 3:
                return UIColor(red:1, green:0.59, blue:0, alpha:1)
            case 4:
                return UIColor(red:0, green:0.58, blue:0.53, alpha:1)
            case 5:
                return UIColor(red:0, green:0.58, blue:0.53, alpha:1)
            case 6:
                return UIColor(red:0.47, green:0.33, blue:0.28, alpha:1)
            case 7:
                return UIColor(red:0.62, green:0.62, blue:0.62, alpha:1)
            default:
                return UIColor(red:0.62, green:0.62, blue:0.62, alpha:1)
        }
    }
    
    struct UI {
        static let darkPrimary = UIColor(red:0.27, green:0.35, blue:0.39, alpha:1)
        static let primary = UIColor(red:0.37, green:0.49, blue:0.54, alpha:1)
        static let lightPrimary = UIColor(red:0.81, green:0.84, blue:0.86, alpha:1)
        static let textIcon = UIColor(red:1, green:1, blue:1, alpha:1)
        static let accent = UIColor(red:1, green:0.75, blue:0.02, alpha:1)
        static let primaryText = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1)
        static let secondaryText = UIColor(red:0.44, green:0.44, blue:0.44, alpha:1)
        static let dividers = UIColor(red:0.71, green:0.71, blue:0.71, alpha:1)
    }
}
