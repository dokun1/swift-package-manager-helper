//
//  PackageViewController.swift
//  swift-package-manager-helper
//
//  Created by David Okun on 2/6/19.
//  Copyright © 2019 David Okun. All rights reserved.
//

import Cocoa

class PackageViewController: NSViewController {
    public var repository: Repository?
    private var currentTextField: NSTextField?
    private var currentOptionalTextField: NSTextField?

    @IBOutlet private var radioButtonFrom: NSButton?
    @IBOutlet private var radioButtonUpToNextMajor: NSButton?
    @IBOutlet private var radioButtonUpToNextMinor: NSButton?
    @IBOutlet private var radioButtonExact: NSButton?
    @IBOutlet private var radioButtonOpenRange: NSButton?
    @IBOutlet private var radioButtonClosedRange: NSButton?
    @IBOutlet private var radioButtonGitBranch: NSButton?
    @IBOutlet private var radioButtonGitRevision: NSButton?
    
    @IBOutlet private var textFieldFrom: NSTextField?
    @IBOutlet private var textFieldUpToNextMajor: NSTextField?
    @IBOutlet private var textFieldUpToNextMinor: NSTextField?
    @IBOutlet private var textFieldExact: NSTextField?
    @IBOutlet private var textFieldOpenRangeMin: NSTextField?
    @IBOutlet private var textFieldOpenRangeMax: NSTextField?
    @IBOutlet private var textFieldClosedRangeMin: NSTextField?
    @IBOutlet private var textFieldClosedRangeMax: NSTextField?
    @IBOutlet private var textFieldGitBranch: NSTextField?
    @IBOutlet private var textFieldGitRevision: NSTextField?
    
    @IBOutlet private var packageStringResult: NSTextField?
    
    @IBOutlet private var copyButton: NSButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        currentTextField = textFieldFrom
        attemptPackageStringUpdate()
    }
    
    @IBAction func radioButtonChanged(_ sender: AnyObject) {
        guard let button = sender as? NSButton else {
            return
        }
        updateEnabledUI(button: button)
    }

    
    @IBAction func copyPackageString(sender: Any) {
        NSPasteboard.general.clearContents()
        guard let copyString = packageStringResult?.stringValue else {
            return
        }
        NSPasteboard.general.writeObjects([copyString as NSPasteboardWriting])
        updateCopyButtonTitle(text: "Copied!")
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { timer in
            self.updateCopyButtonTitle(text: "Copy")
        })
    }
    
    private func updateCopyButtonTitle(text: String) {
        copyButton?.title = text
    }
    
    func attemptPackageStringUpdate() {
        guard let url = repository?.url else {
            return
        }
        switch currentTextField {
        case textFieldFrom:
            guard let versionString = textFieldFrom?.stringValue else {
                return
            }
            if let result = DependencyFactory.resolveString(repositoryURL: url, version: .from(version: versionString)) {
                packageStringResult?.stringValue = result
            }
        case textFieldUpToNextMajor:
            guard let versionString = textFieldUpToNextMajor?.stringValue else {
                return
            }
            if let result = DependencyFactory.resolveString(repositoryURL: url, version: .upToNextMajor(version: versionString)) {
                packageStringResult?.stringValue = result
            }
        case textFieldUpToNextMinor:
            guard let versionString = textFieldUpToNextMinor?.stringValue else {
                return
            }
            if let result = DependencyFactory.resolveString(repositoryURL: url, version: .upToNextMinor(version: versionString)) {
                packageStringResult?.stringValue = result
            }
        case textFieldExact:
            guard let versionString = textFieldExact?.stringValue else {
                return
            }
            if let result = DependencyFactory.resolveString(repositoryURL: url, version: .exact(version: versionString)) {
                packageStringResult?.stringValue = result
            }
        case textFieldOpenRangeMin:
            guard let minVersion = textFieldOpenRangeMin?.stringValue else {
                return
            }
            guard let maxVersion = textFieldOpenRangeMax?.stringValue else {
                return
            }
            if let result = DependencyFactory.resolveString(repositoryURL: url, version: .openRange(from: minVersion, to: maxVersion)) {
                packageStringResult?.stringValue = result
            }
        case textFieldClosedRangeMin:
            guard let minVersion = textFieldClosedRangeMin?.stringValue else {
                return
            }
            guard let maxVersion = textFieldClosedRangeMax?.stringValue else {
                return
            }
            if let result = DependencyFactory.resolveString(repositoryURL: url, version: .closedRange(from: minVersion, to: maxVersion)) {
                packageStringResult?.stringValue = result
            }
        case textFieldGitBranch:
            guard let branch = textFieldGitBranch?.stringValue else {
                return
            }
            if let result = DependencyFactory.resolveString(repositoryURL: url, version: .gitBranch(branch: branch)) {
                packageStringResult?.stringValue = result
            }
        case textFieldGitRevision:
            guard let revision = textFieldGitRevision?.stringValue else {
                return
            }
            if let result = DependencyFactory.resolveString(repositoryURL: url, version: .gitRevision(revision: revision)) {
                packageStringResult?.stringValue = result
            } else {
                packageStringResult?.stringValue = "Invalid commit hash!"
            }
        default:
            break
        }
    }
}

extension PackageViewController { // UI element updating
    func updateEnabledUI(button: NSButton) {
        disableAllTextFields()
        switch button {
        case radioButtonFrom:
            textFieldFrom?.isEnabled = true
            currentTextField = textFieldFrom
        case radioButtonUpToNextMajor:
            textFieldUpToNextMajor?.isEnabled = true
            currentTextField = textFieldUpToNextMajor
        case radioButtonUpToNextMinor:
            textFieldUpToNextMinor?.isEnabled = true
            currentTextField = textFieldUpToNextMinor
        case radioButtonExact:
            textFieldExact?.isEnabled = true
            currentTextField = textFieldExact
        case radioButtonOpenRange:
            textFieldOpenRangeMin?.isEnabled = true
            currentTextField = textFieldOpenRangeMin
            textFieldOpenRangeMax?.isEnabled = true
            currentOptionalTextField = textFieldOpenRangeMax
        case radioButtonClosedRange:
            textFieldClosedRangeMin?.isEnabled = true
            currentTextField = textFieldClosedRangeMin
            textFieldClosedRangeMax?.isEnabled = true
            currentOptionalTextField = textFieldClosedRangeMax
        case radioButtonGitBranch:
            textFieldGitBranch?.isEnabled = true
            currentTextField = textFieldGitBranch
        case radioButtonGitRevision:
            textFieldGitRevision?.isEnabled = true
            currentTextField = textFieldGitRevision
        default:
            break
        }
        attemptPackageStringUpdate()
    }
    
    private func disableAllTextFields() {
        textFieldFrom?.isEnabled = false
        textFieldUpToNextMajor?.isEnabled = false
        textFieldUpToNextMinor?.isEnabled = false
        textFieldExact?.isEnabled = false
        textFieldOpenRangeMin?.isEnabled = false
        textFieldOpenRangeMax?.isEnabled = false
        textFieldClosedRangeMin?.isEnabled = false
        textFieldClosedRangeMax?.isEnabled = false
        textFieldGitBranch?.isEnabled = false
        textFieldGitRevision?.isEnabled = false
        currentTextField = nil
        currentOptionalTextField = nil
    }
}

extension PackageViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        attemptPackageStringUpdate()
    }
}
