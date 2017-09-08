//
//  CheatSheetsViewController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/19/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

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
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.clear
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Color for the text and scopebar border in searchbar - White
        searchBar.tintColor = UIColor.lightPrimaryColor()
        
        // Background Color of the searchbar - Dark Blue
        searchBar.barTintColor = UIColor.darkPrimaryColor()
        searchBar.isTranslucent = true
        
        // prevents tab bar from overlapping last tableviewcell
        tabBarController?.tabBar.isTranslucent = false
        
        self.view.backgroundColor = UIColor.darkPrimaryColor()

    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func readCheatSheetFromJSON() {
        let filePath = Bundle.main.path(forResource: "cheatsheet", ofType: "json")
                
        let cheatSheetsJSONData = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        
        var cheatSheetsData = NSArray()
        
        do {
            cheatSheetsData = (try JSONSerialization.jsonObject(with: cheatSheetsJSONData!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSArray
        } catch let error as NSError {
            print("Error reading file: \(error.localizedDescription)")
        }
        
        
        
        for cheatSheet in cheatSheetsData {
            self.cheatSheetsIndex.append(CheatSheet(data: cheatSheet as! NSDictionary))
        }
    }
    
    func filterCheatSheetsForSearchText(_ searchText: String, platform: String) {
        if platform == "All" {
            if searchText == "" {
                searchResults = cheatSheetsIndex
            } else {
                searchResults = cheatSheetsIndex.filter({ (cheatSheet: CheatSheet) -> Bool in
                    let nameMatch = cheatSheet.name?.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                    return (nameMatch != nil)
                })
            }
        } else {
            searchResults = cheatSheetsIndex.filter({ (cheatSheet: CheatSheet) -> Bool in
                let nameMatch = cheatSheet.name?.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return ((nameMatch != nil && (cheatSheet.platform == platform.lowercased() || cheatSheet.platform == "common")) || searchText == "" && (cheatSheet.platform == platform.lowercased() || cheatSheet.platform == "common"))
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cheatSheetBrowser" {
            let destinationViewController = segue.destination as! CheatSheetBrowserViewController
            let indexPath = (sender as AnyObject).indexPathForSelectedRow
            let cheatSheet = (isSearchActive) ? searchResults : cheatSheetsIndex
            destinationViewController.cheatSheet = cheatSheet[indexPath!!.row]
        }
    }
    
    func getSelectedCheatsheetPlatform() -> String {
        let scopeButtonTitles = searchBar.scopeButtonTitles as [String]!
        let scopeSelection = scopeButtonTitles?[searchBar.selectedScopeButtonIndex]
        return scopeSelection!
    }

}

// MARK: UITableViewDataSource
extension CheatSheetsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return searchResults.count
        } else {
            return cheatSheetsIndex.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "cheatSheet"
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! CheatSheetTableCell
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "cheatSheetBrowser", sender: tableView)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: DZNEmptyDataSetSource
extension CheatSheetsViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyMessage = "No cheatsheets match your search"
        let attributes  = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.primaryTextColor()]
        return NSAttributedString(string: emptyMessage, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyDescription = "We are working on adding cheatsheets for more commands"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = NSTextAlignment.center
        paragraphStyle.lineSpacing = 4.0
        
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.secondaryTextColor(), NSParagraphStyleAttributeName: paragraphStyle]
        
        return NSAttributedString(string: emptyDescription, attributes: attributes)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "nopage")
    }

}

// MARK: UISearchBarDelegate
extension CheatSheetsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterCheatSheetsForSearchText(searchText, platform: getSelectedCheatsheetPlatform())
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let searchText = searchBar.text
        filterCheatSheetsForSearchText(searchText!, platform: getSelectedCheatsheetPlatform())
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
