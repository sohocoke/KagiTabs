import Cocoa
import WebKit



class BrowserContentViewController: NSViewController {

  @objc dynamic
  var tab: Tab? {
    get {
      representedObject as? Tab
    }
    set {
      self.representedObject = newValue
    }
  }
  
  @IBOutlet weak var webView: WKWebView!

  
  var subscriptions: Any?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    subscriptions = [
      // view model observations
      self.publisher(for: \.tab?.url)
        .sink { [unowned self] url in
          if webView.url != url,
            let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
          }
        },
      
      // view observations
      self.publisher(for: \.webView?.title)
        .combineLatest(
          self.publisher(for: \.webView?.url).prepend(nil)
        )
        .sink { [unowned self] title, url in
          if url != nil,
             let title = title {
            self.tab?.label = title
          }
        },
    ]
  }
  
}
