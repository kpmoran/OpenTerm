//
//  AppDelegate.swift
//  Hello World
//
//  Created by Kevin Moran on 10/22/16.
//  Copyright © 2016 Kevin Moran. All rights reserved.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = ["-c", "pluginkit -e use -i \(OpenTermIdentifiers.finderExtension) ; killall Finder"]
        try? task.run()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

