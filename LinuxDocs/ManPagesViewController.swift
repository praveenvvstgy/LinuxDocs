//
//  ManPagesViewController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/5/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit

class ManPagesViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var manPagesIndex = [Int:[ManPage]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.readManPageIndexFromJson()
        self.tableView.reloadData()
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
//        println(self.manPagesIndex[1])
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.manPagesIndex.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section + 1)"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.manPagesIndex[section + 1]?.count as Int!
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "manPage"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as UITableViewCell
        let manPagesInSection = self.manPagesIndex[indexPath.section + 1] as [ManPage]!
        cell.textLabel?.text = manPagesInSection[indexPath.row].name
        return cell
    }

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "manPageBrowser" {
            if let indexPath = self.tableView.indexPathForCell(sender as UITableViewCell) {
                let destinationViewController = segue.destinationViewController as ManPageBrowserViewController
                let manPagesInSection = self.manPagesIndex[indexPath.section + 1] as [ManPage]!
                destinationViewController.manPage = manPagesInSection[indexPath.row]
            }
        }
    }
    
    
}
