import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let appGroupPathname = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        let plistFileLocation = appGroupPathname!.appendingPathComponent("Library").appendingPathComponent("Preferences").appendingPathComponent("\(appGroupID).plist")


        let emptyJSON = try! JSONEncoder().encode([Term]())

        try! emptyJSON.write(to: plistFileLocation)
        defaults.register(defaults: ["forceClickActivated": false])
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
