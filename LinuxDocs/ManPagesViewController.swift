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
    
    let colorArray: [UIColor] = [
        UIColor(red:1, green:0.35, blue:0.25, alpha:1),
        UIColor(red:0.71, green:0.28, blue:0.96, alpha:1),
        UIColor(red:0.56, green:0.56, blue:0.58, alpha:1),
        UIColor(red:0.86, green:0.84, blue:0.78, alpha:1),
        UIColor(red:0.36, green:0.8, blue:0.98, alpha:1),
        UIColor(red:0.36, green:0.8, blue:0.98, alpha:1),
        UIColor(red:0.79, green:0.45, blue:0.88, alpha:1),
        UIColor(red:1, green:0.44, blue:0.15, alpha:1)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        self.readManPageIndexFromJson()
        
        searchController = UISearchController(searchResultsController: nil)
        
//        searchController.dimsBackgroundDuringPresentation = false
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
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorColor = UIColor.clearColor()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        searchController.searchBar.tintColor = UIColor(red:0.91, green:0.91, blue:0.92, alpha:1)
        searchController.searchBar.barTintColor = UIColor(red:0.13, green:0.17, blue:0.22, alpha:1)
        automaticallyAdjustsScrollViewInsets = true
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerSectionView = view as UITableViewHeaderFooterView
        headerSectionView.backgroundView?.backgroundColor = colorArray[section]
        headerSectionView.textLabel.textColor = UIColor.whiteColor()
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
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as ManPageTableCell
        let manPagesInSection: [ManPage]! = (searchController.active) ? self.filteredManPagesIndex[indexPath.section + 1] : self.manPagesIndex[indexPath.section + 1]
        cell.nameLabel.text = manPagesInSection[indexPath.row].name
        cell.sectionLabel.text = manPagesInSection[indexPath.row].section
        cell.descriptionLabel.text = manPagesInSection[indexPath.row].description
        
        cell.backgroundColor = UIColor.clearColor()
        cell.roundedBackground.layer.cornerRadius = 5
        cell.roundedBackground.clipsToBounds = true
        
        cell.sectionLabel.layer.cornerRadius = 10
        cell.sectionLabel.clipsToBounds = true
        
        cell.descriptionLabel.textColor = UIColor(red:0.59, green:0.56, blue:0.59, alpha:1)
        
        cell.nameLabel.textColor = UIColor(red:0.2, green:0.2, blue:0.18, alpha:1)
        
        cell.sectionLabel.textColor = UIColor.whiteColor()
        cell.sectionLabel.backgroundColor = colorArray[manPagesInSection[indexPath.row].section!.toInt()! - 1]
        cell.sectionLabel.layer.cornerRadius = 5
        cell.sectionLabel.clipsToBounds = true
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
