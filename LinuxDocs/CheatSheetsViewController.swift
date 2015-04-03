//
//  CheatSheetsViewController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/19/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit

class CheatSheetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UISearchControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    
    var cheatSheetsIndex = [CheatSheet]()
    var searchResults = [CheatSheet]()
    var searchController: UISearchController!
    
    let colorArray: [String: UIColor] = [
        "common": UIColor(red:0.95, green:0.26, blue:0.21, alpha:1),
        "linux" : UIColor(red:0.25, green:0.32, blue:0.71, alpha:1),
        "osx": UIColor(red:0.29, green:0.68, blue:0.31, alpha:1),
        "sunos": UIColor(red:1, green:0.59, blue:0, alpha:1)
    ]

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readCheatSheetFromJSON()
        
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = [
            "All",
            "Linux",
            "OSX",
            "SunOS"
        ]
        
        searchView.addSubview(searchController.searchBar)
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorColor = UIColor.clearColor()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Color for the text and scopebar border in searchbar - White
        searchController.searchBar.tintColor = UIColor.lightPrimaryColor()
        
        // Background Color of the searchbar - Dark Blue
        searchController.searchBar.barTintColor = UIColor.darkPrimaryColor()
        searchController.searchBar.translucent = true
        
        // prevents tab bar from overlapping last tableviewcell
        tabBarController?.tabBar.translucent = false

    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        tableView.reloadData()
    }
    
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchController.searchBar.endEditing(true)
    }

    
    func readCheatSheetFromJSON() {
        let filePath = NSBundle.mainBundle().pathForResource("cheatsheet", ofType: "json")
        
        var error: NSError?
        
        let cheatSheetsJSONData = NSData(contentsOfFile: filePath!)
        
        if error != nil {
            println("Error reading file: \(error?.localizedDescription)")
        }
        
        let cheatSheetsData = NSJSONSerialization.JSONObjectWithData(cheatSheetsJSONData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSArray
        
        for cheatSheet in cheatSheetsData {
            self.cheatSheetsIndex.append(CheatSheet(data: cheatSheet as NSDictionary))
        }
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        var searchFrame: CGRect = searchController.searchBar.frame
        searchFrame.size.width = searchView.frame.size.width
        searchController.searchBar.frame = searchFrame
        if toInterfaceOrientation.isLandscape {
            tableView.contentInset.top = 0
        } else if toInterfaceOrientation.isPortrait {
            if searchController.active {
                tableView.contentInset.top = 44
                scrollToTop()
            } else {
                tableView.contentInset.top = 0
            }
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
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if !searchController.active {
            tableView.contentInset.top = 0
        }
        let searchText = searchController.searchBar.text
        let scopeButtonTitles = searchController.searchBar.scopeButtonTitles as [String]
        let scopeSelection = scopeButtonTitles[searchController.searchBar.selectedScopeButtonIndex]
        filterCheatSheetsForSearchText(searchText, platform: scopeSelection)
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let searchText = searchController.searchBar.text
        let scopeButtonTitles = searchController.searchBar.scopeButtonTitles as [String]
        let scopeSelection = scopeButtonTitles[selectedScope]
        filterCheatSheetsForSearchText(searchText, platform: scopeSelection)
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResults.count
        } else {
            return self.cheatSheetsIndex.count
        }
    }
    
    func scrollToTop() {
        if (self.numberOfSectionsInTableView(self.tableView) > 0 ) {
            
            var top = NSIndexPath(forRow: Foundation.NSNotFound, inSection: 0);
            self.tableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: true);
        }
    }
    
    // Change the tableview contentInset when the searchController is presented
    func didPresentSearchController(searchController: UISearchController) {
        if UIDevice.currentDevice().orientation.isPortrait {
            self.tableView.contentInset.top = 44
            scrollToTop()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "cheatSheet"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as CheatSheetTableCell
        let cheatSheet = (searchController.active) ? searchResults : cheatSheetsIndex
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("cheatSheetBrowser", sender: tableView)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "cheatSheetBrowser" {
            let destinationViewController = segue.destinationViewController as CheatSheetBrowserViewController
            let indexPath = sender?.indexPathForSelectedRow()
            let cheatSheet = (searchController.active) ? searchResults : cheatSheetsIndex
            destinationViewController.cheatSheet = cheatSheet[indexPath!.row]
        }
    }
    
    

}
