#  KagiTabs

## Notes

- Targets:
  - The app target is set to run on macOS 11 or later. 
  - For quicker iteration on view components, the preview target leverages the Xcode Preview feature 
    available on macOS 14.

- The main focus of this work is the implementation of the toolbar, particularly the tabs as 
  the tab set moves from 1 to many items.
  - Several attempts were prototyped:
    - Only relaying on NSStackView
    - Declarative auto layout constraints defined in Interface Builder only
    - Entirely programmatic layout of tabs
  - The final implementation strategy was to use NSStackView in conjunction with computed layouts,
    which went through some iterations in order to successfuly balance the following objectives:
    - provide a complete realisation of the specs outlined in
      [link1](https://orionfeedback.org/d/92-compact-tabs/82)
      and [link2](https://www.figma.com/proto/Mua4l78XCMh61F8BN6573Z/Untitled?page-id=0%3A1&node-id=17-1775&viewport=528%2C131%2C0.25&scaling=min-zoom)
    - handle unspecified edge cases, such as long webpage titles
    - allow glitch-free animation
    - work properly when used as a view of an NSToolbarItem
    - not be a nightmare to understand and maintain

- Wiring between view model and presentational components is achieved using the following:
  - macOS bindings where straightforward
  -  Combine + KVO

- The following needs further refinement or has only been through basic testing:
  - Pixel-perfect alignment
  - Dark Mode compatibility
  - Keyboard navigation (when 'Keyboard Navigation' setting enabled in System Settings)
  
- The following has been considered out of scope:
  - Main menu
  - Any WKWebView behaviour beyond that out-of-box 
  - Failure cases for networking
  - Localisation
  - Any performance optimisations
