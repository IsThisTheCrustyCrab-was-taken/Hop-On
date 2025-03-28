# Hop-On
### So you can check map-rotations without starting Apex
This is a simple iOS app built in SwiftUI that uses the [unofficial Apex Legends API](https://apexlegendsapi.com/) to display the current map rotations in the different gamemodes/events. 
It also provides a Widget so you don't even need to go into the app to make sure you don't have to wait for Control to end so you can play Gun Run (slight bias on my part)

## Installation
### Download from release
Feel free to check out the newest release - you can download the ipa and then sideload it onto your devices.
### Build and deploy
You can also clone this repo, then just open the repo in Xcode and build/deploy from there.

## Contributing
If there's stuff you want to add, feel free to create an issue/PR, especially if it's stuff that's already in the
## TODOs
- a ton of refactoring (the code is currently quiet messy and could also use some comments)
- general widget improvements (widget refreshing and the count-down to the next rotation is a bit wonky currently)
- better asset loading (currently the app needs to be opened to download map images and show them on the widget because the image-downloads are too large to be handled by the widget)
- other gameplay-related info that might be useful
## Toss a coin to your witcher
This app was built as a passion project by me but more importantly, the API Hop-On relies on also couldn't survive without support.

If you think the API is cool, feel free to support Hugo on Patreon [![Support on Patreon](https://img.shields.io/badge/Support%20on-Patreon-f96854?logo=patreon&style=for-the-badge)](https://www.patreon.com/hugodev)

If you think Hop-On is a cool app, feel free to [![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/senseisnickers)
