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


extension NSView
{
    //
    // Converted to Swift + NSView from:
    // http://stackoverflow.com/a/10700737
    //
    func setAnchorPoint (anchorPoint:CGPoint)
    {
        if let layer = self.layer
        {
            var newPoint = CGPointMake(self.bounds.size.width * anchorPoint.x, self.bounds.size.height * anchorPoint.y)
            var oldPoint = CGPointMake(self.bounds.size.width * layer.anchorPoint.x, self.bounds.size.height * layer.anchorPoint.y)
            
            newPoint = CGPointApplyAffineTransform(newPoint, layer.affineTransform())
            oldPoint = CGPointApplyAffineTransform(oldPoint, layer.affineTransform())
            
            var position = layer.position
            
            position.x -= oldPoint.x
            position.x += newPoint.x
            
            position.y -= oldPoint.y
            position.y += newPoint.y
            
            layer.position = position
            layer.anchorPoint = anchorPoint
        }
    }
}
