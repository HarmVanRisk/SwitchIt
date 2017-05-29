# SwitchIt 🔄
An Enum to Switch statement extension for XCode that is built to work with both Swift and Objective-C.

# What made me build it?
I created it because I hate wasting time typing out all of the switch statements by hand.

# Examples
Lets say you have a regular enum defined somewhere in your code. You'd go to the definition and highlight the area using your cursor.
Once you've done this just go to Editor > SwitchIt > Create Switch to generate your full switch statement. See the output for both Swift and Objective-C below:

![Alt text](SwitchItGifs/regularSwiftSwitch.gif?raw=true "Regular swift switch expansion") ![Alt text](SwitchItGifs/objcSwitchWithEquals.gif?raw=true "Regular Objective-c switch expansion")

Do you not like separating out all of your enum types on different lines? Well, we still have you covered there too. Check out the extra examples below:

![Alt text](SwitchItGifs/swiftSwitchOneLine.gif?raw=true "Swift switch expansion from one line") 
![Alt text](SwitchItGifs/objcSwitchOneLine.gif?raw=true "Objective-C switch expansion from one line")

# Tip
Finding it too slow to move your mouse to the Editor menu all the time? Create a shortcut for SwitchIt by going to XCode > Preferences > Key Bindings and filter by SwitchIt.
From there you can assign any keyboard shortcut you like.

# Installation
- Clone/Download the repo
- Open SwitchIt.xcodeproj
- Enable target signing for both the Application and the XCode Extension using your own developer ID
- Select the application target and then Product > Archive
- Export the archive as a macOS App
- Run the app, then you can quit it but dont delete it
- Go to System Preferences -> Extensions -> Xcode Source Editor and enable the SwitchIt extension
- The menu-item should now be available from Xcode's Editor menu

# License
MIT, see LICENSE
