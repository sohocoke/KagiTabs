//
//  BrowserContentViewController.swift
//  KagiTabsAppKit
//
//  Created by ilo on 29/11/2023.
//

import Cocoa
import WebKit



class BrowserContentViewController: NSViewController {

  @IBOutlet weak var webView: WKWebView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
  
  @IBAction func addressFieldSubmitted(_ sender: NSTextField) {
    let url = URL(string: sender.stringValue)!
    let request = URLRequest(url: url)
    webView.load(request)
  }

}
