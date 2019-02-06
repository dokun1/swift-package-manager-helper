//
//  PackageViewController.swift
//  swift-package-manager-helper
//
//  Created by David Okun on 2/6/19.
//  Copyright © 2019 David Okun. All rights reserved.
//

import Cocoa

class PackageViewController: NSViewController {
    
    @IBOutlet private var packageLabel: NSTextField?
    public var packageString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if let value = packageString {
            packageLabel?.stringValue = value
        }
    }
}
