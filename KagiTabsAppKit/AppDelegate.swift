import Cocoa



@main
class AppDelegate: NSObject, NSApplicationDelegate {

  override init() {
    super.init()
    
    // initialise the value transformer for image binding onto a lazy global.
    _ = dataToNSImageTransformer
  }
  
  func applicationWillFinishLaunching(_ aNotification: Notification) {
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }


}

