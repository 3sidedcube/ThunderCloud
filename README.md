# Thunder Cloud

Thunder Cloud is the controlling SDK for displaying iOS app content hosted using 3SidedCube's [Storm](http://3cu.be/storm) infrastructure. Thunder Cloud displays content in an iOS app based on a series of JSON files, assets and localisations downloaded from your Storm CMS environment. A demo project for what Storm is all about, and what it can do is [here](https://github.com/3sidedcube/iOS-Storm-Demo).

### The CMS


With Storm all the content to be displayed by Thunder Cloud is hosted by our CMS solution. Publishing content is handled by our back end system which is quick and easy to use, and allows updating your app content at any time.

The content from your CMS will be available once you have setup your app correctly in Xcode with the required SDKs, and the app has downloaded it's bundle.

### The SDKs


Thunder Cloud relies on 3 seperate SDKs made by us for: 

+ Displaying content: [Thunder Table](https://github.com/3sidedcube/iOS-ThunderTable)
+ Handling web requests: [Thunder Request](https://github.com/3sidedcube/iOS-ThunderRequest)
+ General useful tools: [Thunder Basics](https://github.com/3sidedcube/iOS-ThunderBasics/tree/master/ThunderBasics)

These 3 SDKs can all be used seperately for easy rendering and setup of table views, handling web requests and other useful bits and bobs respectfully. However together they help us, and you to render your application content.

# Installation

Setting up your app to use Thunder Cloud is a simple and quick process once you have your app set up in the CMS. For now Thunder Cloud is built as a static framework, meaning you will need to include the whole Xcode project in your workspace, as well as the required SDKs listed above.

+ Drag all included files and folders to a location within your existing project.
+ Do the same for all of the above required SDKs.
+ Add all the required frameworks to your Embedded Binaries.
+ Add the run script in [RunScript.txt](RunScript.txt]) to your run scripts phase.
+ Within the run script make sure to change the baseFolder parameter to the correct folder name for your project.
+ Add the following required fileds to your Info.plist file:

		TSCAPIVersion :  <Current API Version> *
	         TSCAppId :  <Your App Id> *
	       TSCBaseURL :  "https://<Your Id>.cubeapis.com" *
	  	 TSCBuildDate :  1401196463 **

	\* These values will be provided to you when setting up your app in the CMS.

	\*\* This will automatically be set when a build is created.
+ Finally, import ThunderCloud into your app delegate file `@import ThunderCloud;` or `import ThunderCloud` if you're swift enclined, and then add the following line to the `application:didFinishLaunchingWithOptions:` method:
	
		self.window.rootViewController = [TSCAppViewController new];

Your project will then compile and run, and as long as you have content set up in the CMS will look all nice and pretty!

# Code Examples

### Overriding how a Storm View displays content

Sometimes cocoa touch views (or views that we have provided) will just not be enough for you, and so you might want to override how we display your CMS content. To do this is simple enough - just add code similar to the following before setting the window's `rootViewController`:

		[TSCStormObject overideClass:[TSCGridPage class] with:[TSCFancyGridPageViewController class]];
		self.window.rootViewController = [TSCAppViewController new];
### Adding native content

And of course sometimes you'll want to have native content for an app, which is not supported under our CMS system, but still have it linked up to other pages in the CMS. To do this we can add the following before we initialise our TSCAppViewController:

		[TSCStormViewController registerNativePageName:@"native_page" toViewControllerClass:[TSCNativeViewController class]];
		
There are multiple ways to override the native behaviour of Thunder Cloud, more of which can be seen in the [Storm Demo Project](https://github.com/3sidedcube/iOS-Storm-Demo)


# License
See [LICENSE.md](LICENSE.md)
