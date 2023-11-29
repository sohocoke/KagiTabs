import Cocoa
import WebKit



class BrowserContentViewController: NSViewController {

  var url: URL? {
    didSet {
      guard let url = url else { return }
      
      let request = URLRequest(url: url)
      webView.load(request)
    }
  }
  
  @IBOutlet weak var webView: WKWebView!
  
}
