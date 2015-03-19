//
//  ManPagesViewController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/5/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit

class ManPagesViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var manPagesIndex = [Int:[ManPage]]()
    var filteredManPagesIndex = [Int:[ManPage]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.readManPageIndexFromJson()
        self.tableView.reloadData()
//        self.searchDisplayController?.displaysSearchBarInNavigationBar = true
        self.navigationController?.hidesBarsOnSwipe = true
        
    }
    
    
    @IBAction func searchButtonClicked(sender: UIBarButtonItem) {
        self.searchDisplayController?.searchBar.becomeFirstResponder()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var newBounds: CGRect = self.tableView.bounds
        if (self.tableView.bounds.origin.y < 44) {
            newBounds.origin.y = newBounds.origin.y + self.searchDisplayController!.searchBar.bounds.size.height
            self.tableView.bounds = newBounds
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.viewWillAppear(true)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y  <= 30 {
            scrollView.scrollEnabled = false
            scrollView.contentOffset = CGPointMake(0, 30)
            scrollView.scrollEnabled = true
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Reads the local JSON file containing the man pages index
    func readManPageIndexFromJson() {
        let filePath = NSBundle.mainBundle().pathForResource("pages", ofType: "json")
        
        var error: NSError?
        
        let manPagesJSONData = NSData(contentsOfFile: filePath!)
        
        if error != nil {
            println("Error reading file: \(error?.localizedDescription)")
        }
        
        let manPagesData = NSJSONSerialization.JSONObjectWithData(manPagesJSONData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSArray
        
        for i in 1...8 {
            var manPageForSection = [ManPage]()
            let j = String(i)
            for manPage in manPagesData[0][j] as NSArray {
                manPageForSection.append(ManPage(data: manPage as NSDictionary))
            }
            self.manPagesIndex[i] = manPageForSection
//            println(manPageForSection.count)
        }
//        println(self.manPagesIndex)
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return self.filteredManPagesIndex.count
        } else {
            return self.manPagesIndex.count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return nil
        } else {
            return "Section \(section + 1)"
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return self.filteredManPagesIndex[section + 1]?.count as Int!
        } else {
            return self.manPagesIndex[section + 1]?.count as Int!
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "manPage"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as UITableViewCell
        var manPagesInSection: [ManPage]!
        if tableView == self.searchDisplayController?.searchResultsTableView {
            manPagesInSection = self.filteredManPagesIndex[indexPath.section + 1] as [ManPage]!
        } else {
            manPagesInSection = self.manPagesIndex[indexPath.section + 1] as [ManPage]!
        }
        cell.textLabel?.text = manPagesInSection[indexPath.row].name
        return cell
    }
    
    func filterManPageForSearchText(searchText: String, section: String = "All") {
        self.filteredManPagesIndex.removeAll(keepCapacity: false)
        if section == "All" {
            for i in 1...8 {
                self.filteredManPagesIndex[i] = self.manPagesIndex[i]?.filter({ (manpage: ManPage) -> Bool in
                    let stringMatch = manpage.name?.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                    return (stringMatch != nil)
                })
            }
        } else {
            let sectionNumber = section.toInt()
            for i in 1...8 {
                self.filteredManPagesIndex[i] = self.manPagesIndex[i]?.filter({ (manpage: ManPage) -> Bool in
                    let stringMatch = manpage.name?.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                    return (stringMatch != nil) && (manpage.section == section)
                })
            }
        }
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        let scopes = self.searchDisplayController?.searchBar.scopeButtonTitles as [String]
        let selectedScope = scopes[self.searchDisplayController!.searchBar.selectedScopeButtonIndex] as String
        self.filterManPageForSearchText(searchString, section: selectedScope)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        let scopes = self.searchDisplayController?.searchBar.scopeButtonTitles as [String]
        self.filterManPageForSearchText(self.searchDisplayController!.searchBar.text, section: scopes[searchOption])
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("manPageBrowser", sender: tableView)
    }

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "manPageBrowser" {
            let destinationViewController = segue.destinationViewController as ManPageBrowserViewController
            if sender as? UITableView == self.searchDisplayController?.searchResultsTableView {
                let indexPath = self.searchDisplayController?.searchResultsTableView.indexPathForSelectedRow()
                let manPagesInSection = self.filteredManPagesIndex[indexPath!.section + 1] as [ManPage]!
                destinationViewController.manPage = manPagesInSection[indexPath!.row]
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow()
                let manPagesInSection = self.manPagesIndex[indexPath!.section + 1] as [ManPage]!
                destinationViewController.manPage = manPagesInSection[indexPath!.row]
            }
        }
    }
    
    
}
