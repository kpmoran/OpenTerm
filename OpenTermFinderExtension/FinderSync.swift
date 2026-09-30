//
//  FinderSync.swift
//  OpenTermFinderExtension
//
//  Created by Kevin Moran on 10/22/16.
//  Copyright © 2016 Kevin Moran. All rights reserved.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {

    var myFolderURL = URL(fileURLWithPath: "/")
    
    override init() {
        super.init()
        
        NSLog("FinderSync() launched from %@", Bundle.main.bundlePath as NSString)
        
        // Set up the directory we are syncing.
        FIFinderSyncController.default().directoryURLs = [self.myFolderURL]
        
    }
    
    // MARK: - Menu and toolbar item support
    
    override var toolbarItemName: String {
        return "OpenTerm"
    }
    
    override var toolbarItemToolTip: String {
        return "Open a Terminal window in the current Finder folder."
    }
    
    override var toolbarItemImage: NSImage {
        // Bundled at toolbar size (16pt, with an @2x version for Retina displays).
        return NSImage(named: "terminal")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        // Clicking the toolbar button opens Terminal immediately instead of showing a menu.
        if menuKind == .toolbarItemMenu {
            openTerminal(nil)
            return NSMenu()
        }
        
        let menu = NSMenu(title: "Open Terminal Here")
        menu.addItem(withTitle: "Open Terminal Here", action: #selector(openTerminal(_:)), keyEquivalent: "")
        return menu
    }
    
    @IBAction func openTerminal(_ sender: AnyObject?) {
        guard let target = FIFinderSyncController.default().targetedURL(),
              let terminalURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: OpenTermIdentifiers.terminal) else {
            return
        }
        NSWorkspace.shared.open([target], withApplicationAt: terminalURL, configuration: NSWorkspace.OpenConfiguration())
    }
}

