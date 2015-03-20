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
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as UITableViewCell
        let cheatSheet = (searchController.active) ? searchResults : cheatSheetsIndex
        cell.textLabel?.text = cheatSheet[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("cheatSheetBrowser", sender: tableView)
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
