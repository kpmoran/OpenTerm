//
//  AppDelegate.swift
//  Hello World
//
//  Created by Kevin Moran on 10/22/16.
//  Copyright © 2016 Kevin Moran. All rights reserved.
//

import Cocoa

// OpenTerm is added to the Finder toolbar by Command-dragging the app onto it.
// Each click launches the app, which opens Terminal in the front Finder
// window's folder and quits.
@main
class AppDelegate: NSObject, NSApplicationDelegate {

    // Returns the front Finder window's folder, or the Desktop when there is no
    // window or it isn't showing a real folder (e.g. Recents).
    static let frontFinderFolderScript = """
        tell application "Finder"
            try
                return POSIX path of (target of front Finder window as alias)
            on error number errorNumber
                if errorNumber is -1743 then error number errorNumber
                return POSIX path of (desktop as alias)
            end try
        end tell
        """

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        enableFinderExtension()

        let folder: URL
        do {
            folder = try frontFinderFolder()
        } catch {
            showError(error)
            NSApp.terminate(nil)
            return
        }

        guard let terminalURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: OpenTermIdentifiers.terminal) else {
            NSApp.terminate(nil)
            return
        }
        NSWorkspace.shared.open([folder], withApplicationAt: terminalURL, configuration: NSWorkspace.OpenConfiguration()) { _, _ in
            DispatchQueue.main.async { NSApp.terminate(nil) }
        }
    }

    // Keeps the right-click "Open Terminal Here" menu available in Finder.
    private func enableFinderExtension() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/pluginkit")
        task.arguments = ["-e", "use", "-i", OpenTermIdentifiers.finderExtension]
        try? task.run()
    }

    private func frontFinderFolder() throws -> URL {
        var errorInfo: NSDictionary?
        let result = NSAppleScript(source: AppDelegate.frontFinderFolderScript)?.executeAndReturnError(&errorInfo)
        guard let path = result?.stringValue else {
            throw NSError(domain: NSOSStatusErrorDomain,
                          code: errorInfo?[NSAppleScript.errorNumber] as? Int ?? 0,
                          userInfo: [NSLocalizedDescriptionKey: errorInfo?[NSAppleScript.errorMessage] as? String ?? "Unknown error"])
        }
        return URL(fileURLWithPath: path, isDirectory: true)
    }

    private func showError(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "OpenTerm couldn't read the current Finder folder."
        if (error as NSError).code == -1743 {
            alert.informativeText = "Allow OpenTerm to control Finder in System Settings → Privacy & Security → Automation."
        } else {
            alert.informativeText = error.localizedDescription
        }
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
