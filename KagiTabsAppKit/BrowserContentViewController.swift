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
    
    self.subscriptions = [
      
      // * view model observations
      
      // load the url in webview.
      self.publisher(for: \.tab?.url, options: [.initial, .new])
        .compactMap { $0 }
        .sink { [weak self] url in
          if self?.webView.url != url {
            let request = URLRequest(url: url)
            self?.webView.load(request)
          }
        },
      
      // quick-and-dirty favicon retrieval.
      self.publisher(for: \.tab?.url, options: [.initial, .new])
        .compactMap { $0 }
        .map { url in
          var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
          components.path = "/favicon.ico"
          components.query = ""
          return components.url!
        }
        .flatMap { url in
          URLSession.shared.dataTaskPublisher(for: url)
        }
        .map { $0.data }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in }) { [weak self] imageData in
          self?.tab?.faviconImageData = imageData
        }
      ,
      
      // * view observations
      
      self.publisher(for: \.webView?.title)
        .compactMap { $0 }
        .assign(to: \.label, on: tab!), // hmmmm... potentially dangerous.
      self.publisher(for: \.webView?.url)
        .assign(to: \.url, on: tab!)
    ]
  }
  
  func tearDown() {
    self.subscriptions = nil
    self.view.removeFromSuperview()
    self.removeFromParent()
  }
}
