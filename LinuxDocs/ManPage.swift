//
//  ManPage.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/5/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import Foundation

class ManPage {
    let name: String?
    let filename: String?
    let section: String?
    let folder: String?
    let description: String!
    
    init(data: NSDictionary) {
        self.name = data["name"] as? String
        self.filename = data["filename"] as? String
        self.section = data["section"] as? String
        self.folder = data["folder"] as? String
        self.description = data["description"] as! String
    }
}