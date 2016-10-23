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
        return "FinderSy"
    }
    
    override var toolbarItemToolTip: String {
        return "Click Here to use OpenTerm to open a Terminal in current Finder directory."
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named:"terminal.png")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        // Produce a menu for the extension.
        let menu = NSMenu(title: "Open Terminal Here")
        menu.addItem(withTitle: "Open Terminal Here", action: #selector(sampleAction(_:)), keyEquivalent: "")
        return menu
    }
    
    @IBAction func sampleAction(_ sender: AnyObject?) {
        let target = FIFinderSyncController.default().targetedURL()
        let task = Process()
        task.launchPath = "/bin/bash"
        if let targetPath = target?.path {
            task.arguments = ["-c", "open -a Terminal "+targetPath]
            task.launch()
        }
    }
}

