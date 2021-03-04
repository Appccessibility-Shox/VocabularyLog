//
//  VocabularyLogApp.swift
//  VocabularyLog
//
//  Created by Patrick Botros on 3/1/21.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let appGroupID: String = "L27L4K8SQU.VocabularyLog"
        let appGroupPathname = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        let plistFileLocation = appGroupPathname!.appendingPathComponent("Library").appendingPathComponent("Preferences").appendingPathComponent("L27L4K8SQU.VocabularyLog.plist")


        let emptyJSON = try! JSONEncoder().encode([Term]())

        try! emptyJSON.write(to: plistFileLocation)
    }
}

@main
struct VocabularyLogApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(HiddenTitleBarWindowStyle())
    }
}
