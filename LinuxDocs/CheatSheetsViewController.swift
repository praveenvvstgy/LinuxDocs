//
//  CheatSheetsViewController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/19/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit

class CheatSheetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    
    var cheatSheetsIndex = [CheatSheet]()
    var searchResults = [CheatSheet]()
    var searchController: UISearchController!
    
    let colorArray: [String: UIColor] = [
        "common": UIColor(red:0.35, green:0.34, blue:0.84, alpha:1),
        "linux" : UIColor(red:0.29, green:0.29, blue:0.29, alpha:1),
        "osx": UIColor(red:0.33, green:0.91, blue:0.81, alpha:1),
        "sunos": UIColor(red:1, green:0.55, blue:0.04, alpha:1)
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readCheatSheetFromJSON()
        
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = [
            "All",
            "Common",
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
        searchController.searchBar.tintColor = UIColor(red:0.91, green:0.91, blue:0.92, alpha:1)
        searchController.searchBar.barTintColor = UIColor(red:0.13, green:0.17, blue:0.22, alpha:1)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
    }
    
    func filterCheatSheetsForSearchText(searchText: String, platform: String) {
        if platform == "All" {
            searchResults = cheatSheetsIndex.filter({ (cheatSheet: CheatSheet) -> Bool in
                let nameMatch = cheatSheet.name?.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return (nameMatch != nil || searchText == "")
            })
        } else {
            searchResults = cheatSheetsIndex.filter({ (cheatSheet: CheatSheet) -> Bool in
                let nameMatch = cheatSheet.name?.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return ((nameMatch != nil && cheatSheet.platform == platform.lowercaseString) || searchText == "" && cheatSheet.platform == platform.lowercaseString)
            })
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "cheatSheet"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as CheatSheetTableCell
        let cheatSheet = (searchController.active) ? searchResults : cheatSheetsIndex
        cell.nameLabel.text = cheatSheet[indexPath.row].name
        cell.platformLabel.text = cheatSheet[indexPath.row].platform
        cell.descriptionLabel.text = cheatSheet[indexPath.row].description
        
        cell.backgroundColor = UIColor.clearColor()
        cell.roundedBackground.layer.cornerRadius = 5
        cell.roundedBackground.clipsToBounds = true
        
        cell.platformLabel.layer.cornerRadius = 10
        cell.platformLabel.clipsToBounds = true
        
        cell.descriptionLabel.textColor = UIColor(red:0.59, green:0.56, blue:0.59, alpha:1)
        
        cell.nameLabel.textColor = UIColor(red:0.2, green:0.2, blue:0.18, alpha:1)
        
        cell.platformLabel.textColor = UIColor.whiteColor()
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
