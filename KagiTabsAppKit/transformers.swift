import AppKit



var valueTransformers: [ValueTransformer] = {
  let dataToImageTransformer = DataToNSImageTransformer()
  ValueTransformer.setValueTransformer(dataToImageTransformer, forName: DataToNSImageTransformer.name)
  
  let tabLabelTransformer = NilOrEmptyTabLabelTransformer()
  ValueTransformer.setValueTransformer(tabLabelTransformer, forName: NilOrEmptyTabLabelTransformer.name)
  
  let urlToStringTransformer = UrlToStringTransformer()
  ValueTransformer.setValueTransformer(urlToStringTransformer, forName: UrlToStringTransformer.name)
  
  return [
    dataToImageTransformer,
    tabLabelTransformer,
    urlToStringTransformer,
  ]
}()


class DataToNSImageTransformer: ValueTransformer {
  static let name = NSValueTransformerName(rawValue: "DataToNSImageTransformer")

  override func transformedValue(_ value: Any?) -> Any? {
    guard let data = value as? Data else {
      return defaultFaviconImage
    }
    
    return NSImage(data: data)
  }
}


class NilOrEmptyTabLabelTransformer: ValueTransformer {
  static let name = NSValueTransformerName(rawValue: "NilOrEmptyTabLabelTransformer")

  override func transformedValue(_ value: Any?) -> Any? {
    guard let label = value as? String,
          !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      return "<No Title>"
    }
    
    return label
  }
}


class UrlToStringTransformer: ValueTransformer {
  static let name = NSValueTransformerName(rawValue: "UrlToStringTransformer")

  override func transformedValue(_ value: Any?) -> Any? {
    guard let url = value as? URL else {
      return nil
    }
    
    return url.absoluteString
  }
}
