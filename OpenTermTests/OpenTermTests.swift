//
//  OpenTermTests.swift
//  OpenTermTests
//
//  Created by Kevin Moran on 10/22/16.
//  Copyright © 2016 Kevin Moran. All rights reserved.
//

import Cocoa
import XCTest

// These tests inspect the built OpenTerm.app rather than launching it, since
// launching the app restarts Finder.
class BundleStructureTests: XCTestCase {

    var appBundle: Bundle!
    var extensionBundle: Bundle!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let productsURL = Bundle(for: BundleStructureTests.self).bundleURL.deletingLastPathComponent()
        let appURL = productsURL.appendingPathComponent("OpenTerm.app")
        appBundle = try XCTUnwrap(Bundle(url: appURL), "OpenTerm.app not found at \(appURL.path)")
        let extensionURL = appURL.appendingPathComponent("Contents/PlugIns/OpenTermFinderExtension.appex")
        extensionBundle = try XCTUnwrap(Bundle(url: extensionURL), "Finder extension is not embedded in OpenTerm.app")
    }

    func testExtensionBundleIdentifierMatchesActivationIdentifier() {
        // AppDelegate enables the extension through pluginkit using this identifier.
        XCTAssertEqual(extensionBundle.bundleIdentifier, OpenTermIdentifiers.finderExtension)
    }

    func testExtensionIdentifierIsPrefixedByAppIdentifier() throws {
        let appIdentifier = try XCTUnwrap(appBundle.bundleIdentifier)
        let extensionIdentifier = try XCTUnwrap(extensionBundle.bundleIdentifier)
        XCTAssertTrue(extensionIdentifier.hasPrefix(appIdentifier + "."))
    }

    func testExtensionDeclaresFinderSyncExtensionPoint() throws {
        let attributes = try XCTUnwrap(extensionBundle.object(forInfoDictionaryKey: "NSExtension") as? [String: Any])
        XCTAssertEqual(attributes["NSExtensionPointIdentifier"] as? String, "com.apple.FinderSync")
        XCTAssertEqual(attributes["NSExtensionPrincipalClass"] as? String, "OpenTermFinderExtension.FinderSync")
    }

    func testToolbarImageIsBundledInExtension() {
        XCTAssertNotNil(extensionBundle.image(forResource: "terminal"))
    }

    func testExecutablesAreNativeForThisMachine() throws {
        #if arch(arm64)
        let native = NSBundleExecutableArchitectureARM64
        #else
        let native = NSBundleExecutableArchitectureX86_64
        #endif
        for bundle in [appBundle!, extensionBundle!] {
            let architectures = try XCTUnwrap(bundle.executableArchitectures?.map { $0.intValue })
            XCTAssertTrue(architectures.contains(native), "\(bundle.bundlePath) has no native slice")
        }
    }

    func testExtensionIsSandboxed() throws {
        // Finder only loads Finder Sync extensions that are signed with the app sandbox entitlement.
        let codesign = Process()
        let output = Pipe()
        codesign.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        codesign.arguments = ["-d", "--entitlements", "-", "--xml", extensionBundle.bundlePath]
        codesign.standardOutput = output
        codesign.standardError = Pipe()
        try codesign.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        codesign.waitUntilExit()
        XCTAssertEqual(codesign.terminationStatus, 0)

        let entitlements = try XCTUnwrap(PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any])
        XCTAssertEqual(entitlements["com.apple.security.app-sandbox"] as? Bool, true)
    }
}

class TerminalTests: XCTestCase {

    func testTerminalAppResolvesFromBundleIdentifier() throws {
        let terminalURL = try XCTUnwrap(NSWorkspace.shared.urlForApplication(withBundleIdentifier: OpenTermIdentifiers.terminal))
        XCTAssertEqual(terminalURL.lastPathComponent, "Terminal.app")
    }
}
