//
//  CheatSheetsViewController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/19/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit

class CheatSheetsViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    var cheatSheetsIndex = [CheatSheet]()
    var searchResults = [CheatSheet]()
    var searchController: UISearchController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readCheatSheetFromJSON()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        
        navigationItem.titleView = searchController.searchBar
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
    
    func filterCheatSheetsForSearchText(searchText: String) {
        searchResults = cheatSheetsIndex.filter({ (cheatSheet: CheatSheet) -> Bool in
            let nameMatch = cheatSheet.name?.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return nameMatch != nil
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        filterCheatSheetsForSearchText(searchText)
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResults.count
        } else {
            return self.cheatSheetsIndex.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "cheatSheet"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as UITableViewCell
        let cheatSheet = (searchController.active) ? searchResults : cheatSheetsIndex
        cell.textLabel?.text = cheatSheet[indexPath.row].name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
