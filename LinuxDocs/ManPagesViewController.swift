//
//  ManPagesViewController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/5/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit

class ManPagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    
    var manPagesIndex = [Int:[ManPage]]()
    var filteredManPagesIndex = [Int:[ManPage]]()
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.readManPageIndexFromJson()
        
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = [
            "All",
            "1",
            "2",
            "3",
            "4",
            "5",
            "7",
            "8"
        ]

        searchView.addSubview(searchController.searchBar)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        navigationController?.hidesBarsOnSwipe = true
        
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
        }
        
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        var searchFrame: CGRect = searchController.searchBar.frame
        searchFrame.size.width = searchView.frame.size.width
        searchController.searchBar.frame = searchFrame
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        let scopeButtonTitles = searchController.searchBar.scopeButtonTitles as [String]
        let scopeSelection = scopeButtonTitles[searchController.searchBar.selectedScopeButtonIndex]
        filterManPageForSearchText(searchText, section: scopeSelection)
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let searchText = searchController.searchBar.text
        let scopeButtonTitles = searchController.searchBar.scopeButtonTitles as [String]
        let scopeSelection = scopeButtonTitles[selectedScope]
        filterManPageForSearchText(searchText, section: scopeSelection)
        tableView.reloadData()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active {
            return self.filteredManPagesIndex.count
        } else {
            return self.manPagesIndex.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return nil
        } else {
            return "Section \(section + 1)"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return self.filteredManPagesIndex[section + 1]?.count as Int!
        } else {
            return self.manPagesIndex[section + 1]?.count as Int!
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "manPage"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as UITableViewCell
        let manPagesInSection: [ManPage]! = (searchController.active) ? self.filteredManPagesIndex[indexPath.section + 1] : self.manPagesIndex[indexPath.section + 1]
        cell.textLabel?.text = manPagesInSection[indexPath.row].name
        return cell
    }
    
    func filterManPageForSearchText(searchText: String, section: String = "All") {
        self.filteredManPagesIndex.removeAll(keepCapacity: false)
        if section == "All" {
            for i in 1...8 {
                self.filteredManPagesIndex[i] = self.manPagesIndex[i]?.filter({ (manpage: ManPage) -> Bool in
                    let stringMatch = manpage.name?.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                    return (stringMatch != nil || searchText == "")
                })
            }
        } else {
            let sectionNumber = section.toInt()
            for i in 1...8 {
                self.filteredManPagesIndex[i] = self.manPagesIndex[i]?.filter({ (manpage: ManPage) -> Bool in
                    let stringMatch = manpage.name?.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                    return ((stringMatch != nil && manpage.section == section) || (searchText == ""  && manpage.section == section))
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("manPageBrowser", sender: tableView)
    }

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "manPageBrowser" {
            let destinationViewController = segue.destinationViewController as ManPageBrowserViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            let manPagesInSection: [ManPage]! = (searchController.active) ? self.filteredManPagesIndex[indexPath!.section + 1] : self.manPagesIndex[indexPath!.section + 1]

            destinationViewController.manPage = manPagesInSection[indexPath!.row]
        }
    }
    
    
}
