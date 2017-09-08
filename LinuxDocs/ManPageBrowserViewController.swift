//
//  ManPageBrowserViewController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/5/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit


class ManPageBrowserViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var manPageBrowser: UIWebView!
    
    
    
    var manPage: ManPage!
    
    override func viewDidLoad() {
        
        let manHTML = Bundle.main.path(forResource: manPage.filename, ofType: "html", inDirectory: "htmlman\(manPage.section!)")
        let manPath = URL(fileURLWithPath: manHTML!, isDirectory: true)
        self.manPageBrowser.loadRequest(URLRequest(url: manPath, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 0))
        self.manPageBrowser.delegate = self
        
        title =  "\(manPage.name!)(\(manPage.section!))"
        
    }
    
    
    func favPage(_ sender: UIButton) {
        let btn = sender
        if btn.isSelected {
            btn.isSelected = false
        } else {
            btn.isSelected = true
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url!.host != nil {
            UIApplication.shared.openURL(request.url!)
        } else {
            if navigationType == UIWebViewNavigationType.linkClicked {
                let requestComponents = request.url!.pathComponents
                let manHTML = Bundle.main.path(forResource: requestComponents[requestComponents.count - 1], ofType: nil, inDirectory: requestComponents[requestComponents.count - 2])
                let manPath = URL(fileURLWithPath: manHTML!, isDirectory: true)
                self.manPageBrowser.loadRequest(URLRequest(url: manPath, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 0))
            } else {
                return true
            }
        }
        return false
    }
}
