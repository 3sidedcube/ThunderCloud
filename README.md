# Thunder Cloud

[![Build Status](https://travis-ci.org/3sidedcube/ThunderCloud.svg?branch=master)](https://travis-ci.org/3sidedcube/ThunderCloud) [![Swift 5.2](http://img.shields.io/badge/swift-5.1-brightgreen.svg)](https://swift.org/blog/swift-5-2-released/) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Apache 2](https://img.shields.io/badge/license-Apache%202-brightgreen.svg)](LICENSE.md)

Thunder Cloud is the controlling SDK for displaying iOS app content hosted using 3SIDEDCUBE’s Storm. Thunder Cloud displays content in an iOS app based on a series of JSON files, assets and localisations downloaded from your Storm CMS environment. A demo project for what Storm is all about, and what it can do is [here](https://github.com/3sidedcube/iOS-Storm-Demo).

### The CMS

With Storm all the content to be displayed by Thunder Cloud is hosted by our CMS solution. Publishing content is handled by our back end system which is quick and easy to use, and allows updating your app content at any time.

The content from your CMS will be available once you have setup your app correctly in Xcode with the required SDKs, and the app has downloaded its bundle.

### The SDKs

Thunder Cloud relies on 4 separate SDKs made by us for:

- Displaying table views: [Thunder Table](https://github.com/3sidedcube/iOS-ThunderTable)
- Handling web requests: [Thunder Request](https://github.com/3sidedcube/iOS-ThunderRequest)
- General useful tools: [Thunder Basics](https://github.com/3sidedcube/iOS-ThunderBasics/tree/master/ThunderBasics)
- Displaying collection views [Thunder Collection](https://github.com/3sidedcube/iOS-ThunderCollection)

These 4 SDKs can all be used separately for easy rendering and setup of table views, handling web requests, utilities and easy rendering of collection views. However, together they help us, and you, to render your application content.

# Installation

Setting up your app to use Thunder Cloud is a simple and quick process once you have your app set up in the CMS. You can choose between a manual installation, or use Carthage.

## Carthage

- Add `github "3sidedcube/ThunderCloud" == 2.1.1` to your Cartfile.
- Run `carthage update --platform ios` to fetch the ThunderCloud dependencies
- Drag `ThunderCloud`, `ThunderTable`, `ThunderRequest`, `ThunderCollection`, and `ThunderBasics` into your project's _Linked Frameworks and Libraries_ section from the `Carthage/Build` folder.
- Add the Build Phases script step as defined [here](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos)
- Add the [quickInstall.sh](quickInstall.sh) script to your project. This will, when run, checkout any Carthage dependencies & download the AppThinner script into your project & mark it as executable.

## Manual

- Drag all included files and folders to a location within your existing project.
- Drag each of the following project files into your project. `ThunderCloud.xcodeproj`, `ThunderTable.xcodeproj`, `ThunderRequest.xcodeproj`, `ThunderCollection.xcodeproj` and finally `ThunderBasics.xcodeproj`
- Add ThunderCloud, ThunderBasics, ThunderTable, `ThunderCollection` and ThunderRequest to your Embedded Binaries.

## After installation

- Add the run script in [RunScript.txt](RunScript.txt) to your run scripts phase as it’s own step.
  - If using Carthage, you _must_ change
  ```bash
  cd "../../Thunder Cloud/ThunderCloud"
  ```
  to
  ```bash
  cd "../../"
  ```
  This is as the AppThinner script is not checked out with the pre-built framework files, and without this change compilation will fail.
- Within the run script make sure to change the baseFolder parameter to the correct folder name for your project.
- Add the following required fields to your Info.plist file:

```
 TSCAPIVersion : <Current API Version> *
      TSCAppId : <Your App Id> *
    TSCBaseURL : "https://<Your Id>.cubeapis.com" *
```

These values will be provided to you when setting up your app in the CMS.

- Finally, import ThunderCloud into your app delegate file `@import ThunderCloud;` or `import ThunderCloud` if you're using swift, and then add the following line to the `application:didFinishLaunchingWithOptions:` method:

`window.rootViewController = AppViewController()`

Your project will then compile and run, and as long as you have content set up in the CMS will look all nice and pretty!

Alternatively you can subclass your `AppDelegate` from `TSCAppDelegate` and we will take care of the rest.

# Code Examples

### Overriding how a Storm View displays content

Sometimes the views that we have provided will just not be enough for you, and so you might want to override how we display your CMS content. To do this is simple enough - just add code similar to the following before setting the window's `rootViewController`:

`StormObjectFactory.shared.override(class: ImageListItem.self, with: MyCustomImageListItem.self)`

### Adding native content

And of course sometimes you'll want to have native content for an app, which is not supported under our CMS system, but still have it linked up to other pages in the CMS. To do this we can add the following before we initialise our TSCAppViewController:

`StormGenerator.register(viewControllerClass: NativeViewController.self, forNativePageName: “native_page”)`
There are multiple ways to override the native behaviour of Thunder Cloud, more of which can be seen in the [Storm Demo Project](https://github.com/3sidedcube/iOS-Storm-Demo)

### Supporting Background Content Downloads

There are two mechanisms for background content downloads:

- `content-available` notifications
- background interval refresh APIs

Neither of these two features will work out of the box, below are the requirements for enabling each. For both of these you will need to enable the "background fetch" background mode in your project settings, as bundles may take longer to download than the time allocated by the system.

#### Content-Available nofications

Firstly, the server team will need to enable content-available notifications for the CMS/App you are using. The app side changes that you will need to make are:

1. Enable the remote notifications capability in Xcode
1. Make sure if you have already enabled this and override the `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` method, that you call `super` within that method so `ThunderCloud` has the opportunity to handle the notification.
1. Make sure wherever you are requesting notification permissions you request a token using `UIApplication.shared.registerForRemoteNotifications()` regardless of if the user gives you permission or not. This is because we will ALWAYS get a token back if we have content-available push entitlement available (you can send the user a silent push even if they've disabled push notifications).

#### Background Refresh

This uses different methods on iOS 13 and iOS 12 due to new APIs added by Apple in iOS 13, however this is all hidden within `ThunderCloud` so you don't need to worry about supporting them independently.

1. Add the `BGTaskSchedulerPermittedIdentifiers` key to your info.plist:

```
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
	<string>com.3sidedcube.thundercloud.contentrefresh</string>
</array>
```

2. Somewhere in your code, make sure to call: 

```
override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    ContentController.shared.scheduleBackgroundUpdates()
}
```

We recommend doing this from the `applicationDidEnterBackground` method on your `AppDelegate`. Custom intervals can be provided to this method.

# License

See [LICENSE.md](LICENSE.md)
