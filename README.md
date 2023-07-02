# Schreiber

A simple notes app, similar to Apple Notes, built with UIKit and CoreData.

![screenshot](https://github.com/Arvonit/Schreiber/assets/27634841/63ebfa35-74fa-4854-8481-585df6f6eb67)

Schreiber has functionality to create notes and organize them in folders. The views are laid out
in a split view controller with three columns — sidebar/folders view, notes view, and note editor
view. In the future, I'd like to update the editor to support rich text. I tried to write a port 
to macOS, but I quickly got frustrated with AppKit. Perhaps SwiftUI will be helpful there.

You will need XCode 14 and iOS 16 to run Schreiber. You may be able to run it on older iOS 
versions, but I haven't tested it.
