import AppKit



extension NSView {
  
  func scaleFromCentre(duration: CGFloat = 0.25) {
    self.wantsLayer = true
    
    let a = CABasicAnimation(keyPath: "transform.scale")
    a.duration = duration
    a.fromValue = 0
    a.toValue = 1
    a.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
    
    // offset x and y to centre to animate from centre.
    let b = CABasicAnimation(keyPath: "transform.translation.x")
    b.duration = duration
    b.fromValue = frame.width / 2
    b.toValue = 0
    b.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
    
    let c = CABasicAnimation(keyPath: "transform.translation.y")
    c.duration = duration
    c.fromValue = frame.height / 2
    c.toValue = 0
    c.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
    
    self.layer?.add(a, forKey: "scale")
    self.layer?.add(b, forKey: "t.x")
    self.layer?.add(c, forKey: "t.y")
    
    self.layer?.setNeedsDisplay()
  }
  
}

