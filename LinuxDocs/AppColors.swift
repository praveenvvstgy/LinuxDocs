//
//  AppColors.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 4/3/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import Foundation

extension UIColor {
    class func darkPrimaryColor() -> (UIColor) {
        return UIColor(red:0.27, green:0.35, blue:0.39, alpha:1)
    }
    
    class func primaryColor() -> (UIColor) {
        return UIColor(red:0.37, green:0.49, blue:0.54, alpha:1)
    }
    
    class func lightPrimaryColor() -> (UIColor) {
        return UIColor(red:0.81, green:0.84, blue:0.86, alpha:1)
    }
    
    class func textIconColor() -> (UIColor) {
        return UIColor(red:1, green:1, blue:1, alpha:1)
    }
    
    class func accentColor() -> (UIColor) {
        return UIColor(red:1, green:0.75, blue:0.02, alpha:1)
    }
    
    class func primaryTextColor() -> (UIColor) {
        return UIColor(red:0.13, green:0.13, blue:0.13, alpha:1)
    }
    
    class func secondaryTextColor() -> (UIColor) {
        return UIColor(red:0.44, green:0.44, blue:0.44, alpha:1)
    }
    
    class func dividerColor() -> (UIColor) {
        return UIColor(red:0.71, green:0.71, blue:0.71, alpha:1)
    }
}