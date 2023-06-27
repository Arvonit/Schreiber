# Schreiber

A rewrite of [Commentarium](https://github.com/Arvonit/Commentarium) to use UIKit intead of 
SwiftUI.

The app has functionality to create notes and organize them in folders. The views are laid out
in a split view controller with three columns — sidebar/folders view, notes view, and note editor
view. I'd like to update the editor to support rich text in the future. I tried to write a 
native macOS app, but AppKit is a bit frustrating so it doesn't work yet.

You will need XCode 14 and iOS 16 to run Schreiber. You may be able to run it on older iOS 
versions, but I haven't tested it.
