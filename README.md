#  KagiTabs

## Notes

- The main focus of this work is the implementation of the tab behaviour.
  - Several attempts were prototyped:
    - Only relaying on NSStackView
    - Declarative auto layout constraints defined in Interface Builder only
    - Entirely programmatic layout of tabs
  - The final implementation strategy was to use NSStackView in conjunction with computed layouts,
    which went through some iterations to balance the following objectives:
    - provide a complete realisation of the specs
    - handle unspecified edge cases, such as long webpage titles
    - allow glitch-free animation
    - work properly when used as a view of an NSToolbarItem
    - not be a nightmare to understand and maintain

- Wiring between view model and presentational components is achieved using the following:
  - macOS bindings where straightforward
  -  Combine + KVO

- The following needs further refinement:
  - Pixel-perfect alignment
  - Dark Mode compatibility
  
- The following has been considered out of scope:
  - Main menu
  - Any WKWebView behaviour beyond those out-of-box 
  - Failure cases for networking
  - Localisation
  - Any performance optimisations
