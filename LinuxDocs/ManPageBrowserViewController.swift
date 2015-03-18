//
//  ManPageBrowserViewController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/5/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit


class ManPageBrowserViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    enum State {
        case Showing
        case Hiding
    }
    
    @IBOutlet weak var manPageBrowser: UIWebView!
    
    
    
    var manPage: ManPage!
    
    override func viewDidLoad() {
        
        let manHTML = NSBundle.mainBundle().pathForResource(manPage.filename, ofType: "html", inDirectory: "htmlman\(manPage.section!)")
        let manPath = NSURL(fileURLWithPath: manHTML!, isDirectory: true)
        self.manPageBrowser.loadRequest(NSURLRequest(URL: manPath!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 0))
        self.manPageBrowser.delegate = self
        
        
        let screenTap = UITapGestureRecognizer(target: self, action: "tapGesture:")
        screenTap.numberOfTapsRequired = 1
        screenTap.delegate = self
        manPageBrowser.addGestureRecognizer(screenTap)
        
        title =  "\(manPage.name!)(\(manPage.section!))"
//        navigationItem.hidesBackButton = true
        
        let rightFavButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        rightFavButton.frame = CGRectMake(40, 10, 40, 40)
        rightFavButton.addTarget(self, action: "favPage:", forControlEvents: UIControlEvents.TouchUpInside)
        rightFavButton.setImage(UIImage(named: "ic_star_outline_black_48dp"), forState: UIControlState.Normal)
        rightFavButton.setImage(UIImage(named: "ic_star_black_48dp"), forState: UIControlState.Selected)
        let barButtonItem: UIBarButtonItem = UIBarButtonItem(customView: rightFavButton)
        navigationItem.rightBarButtonItem = barButtonItem
        
    }
    
    func favPage(sender: UIButton) {
        let btn = sender
        if btn.selected {
            btn.selected = false
        } else {
            btn.selected = true
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL.host != nil {
            UIApplication.sharedApplication().openURL(request.URL)
        } else {
            if navigationType == UIWebViewNavigationType.LinkClicked {
                let requestComponents = request.URL.pathComponents!
                let manHTML = NSBundle.mainBundle().pathForResource(requestComponents[requestComponents.count - 1] as? String, ofType: nil, inDirectory: requestComponents[requestComponents.count - 2] as? String)
                let manPath = NSURL(fileURLWithPath: manHTML!, isDirectory: true)
                self.manPageBrowser.loadRequest(NSURLRequest(URL: manPath!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 0))
            } else {
                return true
            }
        }
        return false
    }
}
