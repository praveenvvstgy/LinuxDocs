//
//  CheatSheetsViewController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/19/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit

class CheatSheetsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var cheatSheetsIndex = [CheatSheet]()
    var searchResults = [CheatSheet]()
    
    let colorArray: [String: UIColor] = [
        "common": UIColor(red:0.95, green:0.26, blue:0.21, alpha:1),
        "linux" : UIColor(red:0.25, green:0.32, blue:0.71, alpha:1),
        "osx": UIColor(red:0.29, green:0.68, blue:0.31, alpha:1),
        "sunos": UIColor(red:1, green:0.59, blue:0, alpha:1)
    ]

    var isSearchActive: Bool {
        if searchBar.text!.isEmpty {
            if getSelectedCheatsheetPlatform() == "All" {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load cheatsheets from disk
        readCheatSheetFromJSON()

        searchBar.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        
        searchBar.scopeButtonTitles = [
            "All",
            "Linux",
            "OSX",
            "SunOS"
        ]
        searchBar.showsScopeBar = true
        searchBarHeightConstraint.constant = 88
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorColor = UIColor.clearColor()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Color for the text and scopebar border in searchbar - White
        searchBar.tintColor = UIColor.lightPrimaryColor()
        
        // Background Color of the searchbar - Dark Blue
        searchBar.barTintColor = UIColor.darkPrimaryColor()
        searchBar.translucent = true
        
        // prevents tab bar from overlapping last tableviewcell
        tabBarController?.tabBar.translucent = false
        
        self.view.backgroundColor = UIColor.darkPrimaryColor()

    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func readCheatSheetFromJSON() {
        let filePath = NSBundle.mainBundle().pathForResource("cheatsheet", ofType: "json")
                
        let cheatSheetsJSONData = NSData(contentsOfFile: filePath!)
        
        var cheatSheetsData = NSArray()
        
        do {
            cheatSheetsData = (try NSJSONSerialization.JSONObjectWithData(cheatSheetsJSONData!, options: NSJSONReadingOptions.MutableContainers)) as! NSArray
        } catch let error as NSError {
            print("Error reading file: \(error.localizedDescription)")
        }
        
        
        
        for cheatSheet in cheatSheetsData {
            self.cheatSheetsIndex.append(CheatSheet(data: cheatSheet as! NSDictionary))
        }
    }
    
    func filterCheatSheetsForSearchText(searchText: String, platform: String) {
        if platform == "All" {
            if searchText == "" {
                searchResults = cheatSheetsIndex
            } else {
                searchResults = cheatSheetsIndex.filter({ (cheatSheet: CheatSheet) -> Bool in
                    let nameMatch = cheatSheet.name?.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                    return (nameMatch != nil)
                })
            }
        } else {
            searchResults = cheatSheetsIndex.filter({ (cheatSheet: CheatSheet) -> Bool in
                let nameMatch = cheatSheet.name?.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return ((nameMatch != nil && (cheatSheet.platform == platform.lowercaseString || cheatSheet.platform == "common")) || searchText == "" && (cheatSheet.platform == platform.lowercaseString || cheatSheet.platform == "common"))
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "cheatSheetBrowser" {
            let destinationViewController = segue.destinationViewController as! CheatSheetBrowserViewController
            let indexPath = sender?.indexPathForSelectedRow
            let cheatSheet = (isSearchActive) ? searchResults : cheatSheetsIndex
            destinationViewController.cheatSheet = cheatSheet[indexPath!!.row]
        }
    }
    
    func getSelectedCheatsheetPlatform() -> String {
        let scopeButtonTitles = searchBar.scopeButtonTitles as [String]!
        let scopeSelection = scopeButtonTitles[searchBar.selectedScopeButtonIndex]
        return scopeSelection
    }

}

// MARK: UITableViewDataSource
extension CheatSheetsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return searchResults.count
        } else {
            return cheatSheetsIndex.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "cheatSheet"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! CheatSheetTableCell
        let cheatSheet = (isSearchActive) ? searchResults : cheatSheetsIndex
        cell.nameLabel.text = cheatSheet[indexPath.row].name
        cell.platformLabel.text = cheatSheet[indexPath.row].platform
        cell.descriptionLabel.text = cheatSheet[indexPath.row].description
        
        cell.backgroundColor = UIColor.lightPrimaryColor()
        cell.roundedBackground.layer.cornerRadius = 5
        cell.roundedBackground.clipsToBounds = true
        
        cell.platformLabel.layer.cornerRadius = 10
        cell.platformLabel.clipsToBounds = true
        
        cell.descriptionLabel.textColor = UIColor.secondaryTextColor()
        
        cell.nameLabel.textColor = UIColor.primaryTextColor()
        
        cell.platformLabel.textColor = UIColor.textIconColor()
        cell.platformLabel.backgroundColor = colorArray[cheatSheet[indexPath.row].platform!]
        cell.platformLabel.layer.cornerRadius = 5
        cell.platformLabel.clipsToBounds = true
        return cell
    }

}

// MARK: UITableViewDelegate
extension CheatSheetsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("cheatSheetBrowser", sender: tableView)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: DZNEmptyDataSetSource
extension CheatSheetsViewController: DZNEmptyDataSetSource {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyMessage = "No cheatsheets match your search"
        let attributes  = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18), NSForegroundColorAttributeName: UIColor.primaryTextColor()]
        return NSAttributedString(string: emptyMessage, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyDescription = "We are working on adding cheatsheets for more commands"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Center
        paragraphStyle.lineSpacing = 4.0
        
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: UIColor.secondaryTextColor(), NSParagraphStyleAttributeName: paragraphStyle]
        
        return NSAttributedString(string: emptyDescription, attributes: attributes)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "nopage")
    }

}

// MARK: UISearchBarDelegate
extension CheatSheetsViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterCheatSheetsForSearchText(searchText, platform: getSelectedCheatsheetPlatform())
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let searchText = searchBar.text
        filterCheatSheetsForSearchText(searchText!, platform: getSelectedCheatsheetPlatform())
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
