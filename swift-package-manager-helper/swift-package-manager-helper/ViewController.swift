//
//  ViewController.swift
//  swift-package-manager-helper
//
//  Created by David Okun on 2/6/19.
//  Copyright © 2019 David Okun. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet private var searchButton: NSButton?
    @IBOutlet private var searchField: NSTextField?
    @IBOutlet private var resultsTableView: NSTableView?
    fileprivate var latestResults: [Repository]?

    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView?.dataSource = self
        resultsTableView?.delegate = self
        self.title = "SPM Helper"
    }
    
    @IBAction func searchButtonClicked(sender: Any) {
        guard let query = searchField?.stringValue else {
            return
        }
        send(query)
    }
    
    private func send(_ query: String) {
        searchButton?.isEnabled = false
        searchButton?.title = "Searching..."
        Github.search(for: query) { repositories, error in
            self.searchButton?.isEnabled = true
            self.searchButton?.title = "Search"
            self.latestResults = repositories
            self.resultsTableView?.reloadData()
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "repoSelectedSegue" {
            guard let repository = sender as? Repository else {
                return
            }
            guard let controller = segue.destinationController as? PackageViewController else {
                return
            }
            
            controller.packageString = repository.url
        }
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return latestResults?.count ?? 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let repositories = latestResults else {
            return nil
        }
        let repository = repositories[row]
        let result = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        if (tableColumn?.identifier)!.rawValue == "repositoryNameColumn" {
            result.textField?.stringValue = repository.name
            return result
        } else {
            result.textField?.stringValue = "\(repository.stars)"
            return result
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        guard let repositories = latestResults else {
            return false
        }
        let repository = repositories[row]
        performSegue(withIdentifier: "repoSelectedSegue", sender: repository)
        return true
    }
}

