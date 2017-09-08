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


class ManPagesViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    lazy var manPagesIndex: [String: [ManPage]] = [:]
    var filteredManPagesIndex: [String: [ManPage]] = [:]
    
    @IBOutlet weak var searchbarHeightConstraint: NSLayoutConstraint!
    
    var isSearchActive: Bool {
        if let searchText = searchBar.text, searchText.isEmpty {
            if selectedSection == 0 {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    var selectedSection: Int {
        return searchBar.selectedScopeButtonIndex
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Read man pages from disk
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
        searchBar.tintColor = Color.UI.lightPrimary
        
        // Background Color of the searchbar - Dark Blue
        searchBar.barTintColor = Color.UI.darkPrimary
        searchBar.isTranslucent = true
        
        tableView.dataSource = self
        tableView.delegate = self

        // Remove footer of the tableview
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Remove the tableview seperator by giving it clear color
        tableView.separatorColor = UIColor.clear
        
        // Estimated height for tableview cell
        tableView.estimatedRowHeight = 80.0
        
        // Use Auto resizing cell
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Remove the title from the back button and use only one arrow
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        // prevents tab bar from overlapping last tableviewcell
        tabBarController?.tabBar.isTranslucent = false
        
        view.backgroundColor = Color.UI.darkPrimary
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Reads the local JSON file containing the man pages index
    func readManPageIndexFromJson() {
        DispatchQueue.global(qos: .background).async {
            
            guard let filePath = Bundle.main.path(forResource: "pages", ofType: "json"),
                let manPagesJSONData = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
            let manPagesData = (try? JSONSerialization.jsonObject(with: manPagesJSONData, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: [[String: Any]]] else {
                    return
            }
            
            for (section, manPages) in manPagesData {
                self.manPagesIndex[section] = manPages.map({ (manPageDict) -> ManPage in
                    return ManPage(data: manPageDict)
                })
            }
            
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    
    // Filters the manpages based on the search text and stores it in filteredManPagesIndex
    func filterManPageForSearchText(_ searchText: String, section: Int) {

        if section == 0 {
            if searchText.isEmpty {
                filteredManPagesIndex = manPagesIndex
            } else {
                manPagesIndex.forEach({ (key, value) in
                    
                })
                manPagesIndex.forEach({ ((manPagesEntry)) in
                    filteredManPagesIndex[String(section)] = manPages.filter({ (manPage) in
                        let stringMatch = manPage.name?.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                        return stringMatch != nil
                    })
                })
            }
        } else {
            let section = String(section)
            if searchText.isEmpty {
                filteredManPagesIndex[section] = manPagesIndex[section]
            } else {
                filteredManPagesIndex[section] = manPagesIndex[section]?.filter({ (manPage) in
                    let stringMatch = manPage.name?.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                    return stringMatch != nil
                })
            }
        }
        tableView.reloadData()
    }
    
    // prepareForSegue before performing the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "manPageBrowser" {
            let destinationViewController = segue.destination as! ManPageBrowserViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let manPagesInSection: [ManPage]! = (!searchBar.text!.isEmpty) ? self.filteredManPagesIndex[indexPath!.section + 1] : self.manPagesIndex[indexPath!.section + 1]

            destinationViewController.manPage = manPagesInSection[indexPath!.row]
        }
    }
    
    // Hide keyboard when clicked outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.endEditing(true)
    }
}

// MARK: UITableViewDataSource
extension ManPagesViewController: UITableViewDataSource {
    // Number of sections in the tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearchActive {
            return filteredManPagesIndex.count
        } else {
            return manPagesIndex.count
        }
    }
    
    // Set the title of the section header, return nil if no rows in that section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return nil
        } else {
            return "Section \(section + 1)"
        }
    }
    
    // Number of rows in each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return filteredManPagesIndex[section + 1]?.count as Int!
        } else {
            return manPagesIndex[section + 1]?.count as Int!
        }
    }
    
    
    // Create the ManPageTableCell for a given section and row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "manPage"
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ManPageTableCell
        let manPagesInSection: [ManPage]! = (!searchBar.text!.isEmpty) ? self.filteredManPagesIndex[indexPath.section + 1] : self.manPagesIndex[indexPath.section + 1]
        cell.nameLabel.text = manPagesInSection[indexPath.row].name
        cell.sectionLabel.text = manPagesInSection[indexPath.row].section
        cell.descriptionLabel.text = manPagesInSection[indexPath.row].description
        
        cell.backgroundColor = Color.UI.lightPrimary
        cell.roundedBackground.layer.cornerRadius = 5
        cell.roundedBackground.clipsToBounds = true
        
        cell.sectionLabel.layer.cornerRadius = 10
        cell.sectionLabel.clipsToBounds = true
        
        cell.descriptionLabel.textColor = Color.UI.secondaryText
        
        cell.nameLabel.textColor = Color.UI.primaryText
        
        cell.sectionLabel.textColor = Color.UI.textIcon
        cell.sectionLabel.backgroundColor = Color.Section(value: Int(manPagesInSection[indexPath.row].section!)! - 1)
        cell.sectionLabel.layer.cornerRadius = 5
        cell.sectionLabel.clipsToBounds = true
        return cell
    }
}

// MARK: UITableViewDelegate
extension ManPagesViewController: UITableViewDelegate {
    // Peform Segue when a tableview cell row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "manPageBrowser", sender: tableView)
        // deseelect the selected row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Change text color of section headers to white
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerSectionView = view as! UITableViewHeaderFooterView
        headerSectionView.backgroundView?.backgroundColor = colorArray[section]
        headerSectionView.textLabel!.textColor = UIColor.textIconColor()
    }
}

// MARK: DZNEmptyDataSetSource
extension ManPagesViewController: DZNEmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyMessage = "No manpages match your search"
        let attributes  = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.primaryTextColor()]
        return NSAttributedString(string: emptyMessage, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyDescription = "You can request new manpages to be added in the next update"
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
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.primaryTextColor()]
        
        return NSAttributedString(string: "Request New ManPage", attributes: attributes)
    }
    
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        let rectInsets = UIEdgeInsetsMake(-23.0, -60.0, -23.0, -60.0);
        let capInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
        
        return UIImage(named: "roundbutton")?.resizableImage(withCapInsets: capInsets, resizingMode: UIImageResizingMode.stretch).withAlignmentRectInsets(rectInsets)
    }
}

// MARK: DZNEmptyDataSetDelegate
extension ManPagesViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        let feedbackViewController = CTFeedbackViewController(topics: CTFeedbackViewController.defaultTopics(), localizedTopics: CTFeedbackViewController.defaultLocalizedTopics())
        feedbackViewController?.toRecipients = NSArray(array: [NSString(string: "support@hitherto.desk-mail.com")]) as [AnyObject]
        feedbackViewController?.tableView.backgroundColor = UIColor.lightPrimaryColor()
        let navigationController = UINavigationController(rootViewController: feedbackViewController!)
        self.present(navigationController, animated: true, completion: nil)
    }
}

// MARK: UISearchBarDelegate
extension ManPagesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterManPageForSearchText(searchText, section: selectedManPageSection())
        tableView.reloadData()
    }
    
    //  Change Search Results when selected scopebar button changes
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scopeSelection = getSelectedManPageSection()
        filterManPageForSearchText(searchBar.text!, section: scopeSelection)
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
