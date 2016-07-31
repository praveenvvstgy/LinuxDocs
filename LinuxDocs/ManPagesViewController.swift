//
//  ManPagesViewController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/5/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import CTFeedback


class ManPagesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    lazy var manPagesIndex = [Int:[ManPage]]()
    var filteredManPagesIndex = [Int:[ManPage]]()
    
    // Array of UIColors, used as background color for section indicators
    let colorArray: [UIColor] = [
        UIColor(red:0.95, green:0.26, blue:0.21, alpha:1),
        UIColor(red:0.25, green:0.32, blue:0.71, alpha:1),
        UIColor(red:0.29, green:0.68, blue:0.31, alpha:1),
        UIColor(red:1, green:0.59, blue:0, alpha:1),
        UIColor(red:0, green:0.58, blue:0.53, alpha:1),
        UIColor(red:0, green:0.58, blue:0.53, alpha:1),
        UIColor(red:0.47, green:0.33, blue:0.28, alpha:1),
        UIColor(red:0.62, green:0.62, blue:0.62, alpha:1)
    ]
    @IBOutlet weak var searchbarHeightConstraint: NSLayoutConstraint!
    
    var isSearchActive: Bool {
        if searchBar.text!.isEmpty {
            if getSelectedManPageSection() == "All" {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        
        // Read man page from disk
        self.readManPageIndexFromJson()
        
        searchBar.delegate = self
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        // Set the titles of the scope bar, indicating man page sections
        searchBar.scopeButtonTitles = [
            "All",
            "1",
            "2",
            "3",
            "4",
            "5",
            "7",
            "8"
        ]
        searchBar.showsScopeBar = true
        // A silly bug in storyboard requires us to increase the height here
        searchbarHeightConstraint.constant = 88
        
        // Color for the text and scopebar border in searchbar - White
        searchBar.tintColor = UIColor.lightPrimaryColor()
        
        // Background Color of the searchbar - Dark Blue
        searchBar.barTintColor = UIColor.darkPrimaryColor()
        searchBar.translucent = true
        
        tableView.dataSource = self
        tableView.delegate = self

        // Remove footer of the tableview
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Remove the tableview seperator by giving it clear color
        tableView.separatorColor = UIColor.clearColor()
        
        // Estimated height for tableview cell
        tableView.estimatedRowHeight = 80.0
        
        // Use Auto resizing cell
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Remove the title from the back button and use only one arrow
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // prevents tab bar from overlapping last tableviewcell
        tabBarController?.tabBar.translucent = false
        
        view.backgroundColor = UIColor.darkPrimaryColor()
    }
    
    // White color of Status Bar Title for dark background
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Reads the local JSON file containing the man pages index
    func readManPageIndexFromJson() {
        
        let qualityOfServiceClass = Int(QOS_CLASS_BACKGROUND.rawValue)
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            let filePath = NSBundle.mainBundle().pathForResource("pages", ofType: "json")
                        
            let manPagesJSONData = NSData(contentsOfFile: filePath!)
            
            var manPagesData = NSArray()
            
            do {
                manPagesData = (try NSJSONSerialization.JSONObjectWithData(manPagesJSONData!, options: NSJSONReadingOptions.MutableContainers)) as! NSArray
            } catch let error as NSError {
                print("Error reading file: \(error.localizedDescription)")
            }
            
            
            for i in 1...8 {
                var manPageForSection = [ManPage]()
                let j = String(i)
                for manPage in manPagesData[0][j] as! NSArray {
                    manPageForSection.append(ManPage(data: manPage as! NSDictionary))
                }
                self.manPagesIndex[i] = manPageForSection
            }

            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        })
    }
    
    // Filters the manpages based on the search text and stores it in filteredManPagesIndex
    func filterManPageForSearchText(searchText: String, section: String = "All") {
        for i in 1...8 {
            self.filteredManPagesIndex[i] = []
        }
        if section == "All" {
            if searchText.isEmpty {
                filteredManPagesIndex = manPagesIndex
            } else {
                for i in 1...8 {
                    self.filteredManPagesIndex[i] = self.manPagesIndex[i]?.filter({ (manpage: ManPage) -> Bool in
                        let stringMatch = manpage.name?.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                        return (stringMatch != nil)
                    })
                }
            }
        } else {
            let sectionNumber = Int(section)
            if searchText == "" {
                filteredManPagesIndex[sectionNumber!] = manPagesIndex[sectionNumber!]
            } else {
                for i in 1...8 {
                    filteredManPagesIndex[i] = manPagesIndex[i]?.filter({ (manpage: ManPage) -> Bool in
                        let stringMatch = manpage.name?.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                        return (stringMatch != nil && manpage.section == section)
                    })
                }
            }
        }
        tableView.reloadData()
    }
    
    // prepareForSegue before performing the segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "manPageBrowser" {
            let destinationViewController = segue.destinationViewController as! ManPageBrowserViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let manPagesInSection: [ManPage]! = (!searchBar.text!.isEmpty) ? self.filteredManPagesIndex[indexPath!.section + 1] : self.manPagesIndex[indexPath!.section + 1]

            destinationViewController.manPage = manPagesInSection[indexPath!.row]
        }
    }
    
    func getSelectedManPageSection() -> String {
        let scopeButtonTitles = searchBar.scopeButtonTitles as [String]!
        let scopeSelection = scopeButtonTitles[searchBar.selectedScopeButtonIndex]
        return scopeSelection
    }
    
    // Hide keyboard when clicked outside
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchBar.endEditing(true)
    }
}

// MARK: UITableViewDataSource
extension ManPagesViewController: UITableViewDataSource {
    // Number of sections in the tableview
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isSearchActive {
            return filteredManPagesIndex.count
        } else {
            return manPagesIndex.count
        }
    }
    
    // Set the title of the section header, return nil if no rows in that section
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return nil
        } else {
            return "Section \(section + 1)"
        }
    }
    
    // Number of rows in each section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return filteredManPagesIndex[section + 1]?.count as Int!
        } else {
            return manPagesIndex[section + 1]?.count as Int!
        }
    }
    
    
    // Create the ManPageTableCell for a given section and row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "manPage"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! ManPageTableCell
        let manPagesInSection: [ManPage]! = (!searchBar.text!.isEmpty) ? self.filteredManPagesIndex[indexPath.section + 1] : self.manPagesIndex[indexPath.section + 1]
        cell.nameLabel.text = manPagesInSection[indexPath.row].name
        cell.sectionLabel.text = manPagesInSection[indexPath.row].section
        cell.descriptionLabel.text = manPagesInSection[indexPath.row].description
        
        cell.backgroundColor = UIColor.lightPrimaryColor()
        cell.roundedBackground.layer.cornerRadius = 5
        cell.roundedBackground.clipsToBounds = true
        
        cell.sectionLabel.layer.cornerRadius = 10
        cell.sectionLabel.clipsToBounds = true
        
        cell.descriptionLabel.textColor = UIColor.secondaryTextColor()
        
        cell.nameLabel.textColor = UIColor.primaryTextColor()
        
        cell.sectionLabel.textColor = UIColor.textIconColor()
        cell.sectionLabel.backgroundColor = colorArray[Int(manPagesInSection[indexPath.row].section!)! - 1]
        cell.sectionLabel.layer.cornerRadius = 5
        cell.sectionLabel.clipsToBounds = true
        return cell
    }
}

// MARK: UITableViewDelegate
extension ManPagesViewController: UITableViewDelegate {
    // Peform Segue when a tableview cell row is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("manPageBrowser", sender: tableView)
        // deseelect the selected row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Change text color of section headers to white
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerSectionView = view as! UITableViewHeaderFooterView
        headerSectionView.backgroundView?.backgroundColor = colorArray[section]
        headerSectionView.textLabel!.textColor = UIColor.textIconColor()
    }
}

// MARK: DZNEmptyDataSetSource
extension ManPagesViewController: DZNEmptyDataSetSource {
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyMessage = "No manpages match your search"
        let attributes  = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18), NSForegroundColorAttributeName: UIColor.primaryTextColor()]
        return NSAttributedString(string: emptyMessage, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyDescription = "You can request new manpages to be added in the next update"
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
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: UIColor.primaryTextColor()]
        
        return NSAttributedString(string: "Request New ManPage", attributes: attributes)
    }
    
    func buttonBackgroundImageForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> UIImage! {
        let rectInsets = UIEdgeInsetsMake(-23.0, -60.0, -23.0, -60.0);
        let capInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
        
        return UIImage(named: "roundbutton")?.resizableImageWithCapInsets(capInsets, resizingMode: UIImageResizingMode.Stretch).imageWithAlignmentRectInsets(rectInsets)
    }
}

// MARK: DZNEmptyDataSetDelegate
extension ManPagesViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        let feedbackViewController = CTFeedbackViewController(topics: CTFeedbackViewController.defaultTopics(), localizedTopics: CTFeedbackViewController.defaultLocalizedTopics())
        feedbackViewController.toRecipients = NSArray(array: [NSString(string: "support@hitherto.desk-mail.com")]) as [AnyObject]
        feedbackViewController.tableView.backgroundColor = UIColor.lightPrimaryColor()
        let navigationController = UINavigationController(rootViewController: feedbackViewController)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
}

// MARK: UISearchBarDelegate
extension ManPagesViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterManPageForSearchText(searchText, section: getSelectedManPageSection())
        tableView.reloadData()
    }
    
    //  Change Search Results when selected scopebar button changes
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scopeSelection = getSelectedManPageSection()
        filterManPageForSearchText(searchBar.text!, section: scopeSelection)
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
