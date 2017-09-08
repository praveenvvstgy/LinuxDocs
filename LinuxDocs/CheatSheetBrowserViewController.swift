//
//  CheatSheetBrowserViewController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/19/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit

class CheatSheetBrowserViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var cheatSheetBrowser: UIWebView!
    
    var cheatSheet: CheatSheet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cheatSheetHTML = Bundle.main.path(forResource: cheatSheet.name!, ofType: "html", inDirectory: "cheatsheet")
        let cheatSheetPath = URL(fileURLWithPath: cheatSheetHTML!, isDirectory: true)
        self.cheatSheetBrowser.loadRequest(URLRequest(url: cheatSheetPath, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 0))
        self.cheatSheetBrowser.delegate = self
        
        title =  self.cheatSheet.name
        
    }


}
