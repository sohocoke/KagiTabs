import AppKit

class TestViewAppearAnimationViewController: NSViewController {
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    var imageView = NSImageView(image: NSImage(systemSymbolName: "doc", accessibilityDescription: nil)!)
    imageView.imageScaling = .scaleProportionallyUpOrDown

    var view: NSView = imageView

    view = MyButton()
    
    view.setFrameSize(.init(width: 100, height: 100))
    view.setDebugBorder(.brown)

    self.view.addSubview(view)
      
    view.scaleFromCentre()
  }
}


#Preview(traits: .sizeThatFitsLayout) {
  TestViewAppearAnimationViewController()
}


class MyButton: NSButton {
  convenience init() {
    self.init(title: "Boom", target: nil, action: nil)
  }
  
}


func animateScale(view: NSView, from: CGFloat, to: CGFloat, duration: Double) {
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.fromValue = from
    animation.toValue = to
    animation.duration = duration
  animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
  view.layer?.add(animation, forKey: "scale")
    view.layer?.transform = CATransform3DMakeScale(to, to, 1)
}
