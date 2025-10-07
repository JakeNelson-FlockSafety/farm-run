## Step by Step Guide:

**1. Get the Tools**
* **Install Xcode** (free from the Mac App Store).
    * This is Apple’s official IDE for iOS/macOS development. It comes with:
        * A code editor
        * UI builder
        * iPhone/iPad simulator
        * Build & debugging tools
* Install Xcode Command Line Tools (they usually come with Xcode, but you can check with xcode-select --install in Terminal).

**2. Set Up Your Developer Account**
* Apple ID: You can build & run apps on your iPhone for free using your regular Apple ID.
* Apple Developer Program ($99/year): Needed only if you want to publish on the App Store or access advanced features (like TestFlight for beta testing, push notifications, in-app purchases).

**3. Create a Fork of farm-run and Open in Xcode**
1. Create a fork of this repo
2. Clone your repo to your local machine 
	 * [Here is a helpful sheet of git commands](https://education.github.com/git-cheat-sheet-education.pdf)
3. Open Xcode → File > Open > farm-run
4. Run it in the Simulator (e.g., iPhone 15 Pro).

**4. Run on Your iPhone**
5. Connect your iPhone via USB (or Wi-Fi if enabled).
6. In Xcode, select your iPhone as the run target.
7. The first time, you’ll need to trust your developer certificate:
    * On iPhone: Settings > General > VPN & Device Management > Developer App → Trust.
8. Hit Run ▶ and see your app on your phone!


**5. Technical details:**
* this game uses [Spritekit](https://developer.apple.com/documentation/spritekit/) - a 2D game framework
