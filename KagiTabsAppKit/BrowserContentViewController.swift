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
      self.publisher(for: \.tab?.url)
        .sink { [unowned self] url in
        if webView.url != url,
          let url = url {
          let request = URLRequest(url: url)
          webView.load(request)
        }
      }
    ]
  }
  
}

