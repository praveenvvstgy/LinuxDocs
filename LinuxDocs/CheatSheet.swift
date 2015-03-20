//
//  CheatSheet.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/19/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import Foundation

class CheatSheet {
    let name: String?
    let filename: String?
    let platform: String?
    let description: String!
    
    init(data: NSDictionary) {
        self.name = data["name"] as? String
        self.filename = data["filename"] as? String
        self.platform = data["platform"] as? String
        self.description = data["description"] as? String
    }
}