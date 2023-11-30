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
      self.publisher(for: \.webView?.url)
        .assign(to: \.url, on: tab!)  // hmmmm... potentially dangerous.
    ]
  }
  
  func tearDown() {
    self.subscriptions = nil
    self.view.removeFromSuperview()
    self.removeFromParent()
  }
}
