How do I setup a new project?
* Tuist vs XcodeGen
* Continuous Integration
* AI Integration
* Fastlane Integration
* How do I setup a Swift Package
* How do I setup a Open Source Swift Package
* How do I setup a Mono Repo with multiple Packages


With the advent of AI coding tools like Claude Code, it's become easier to get started build a new app. However as much as you can trust these tools there are some important steps you can take to automate everything from project creation to publishing on the app store. I'd like to go over some steps I take to automate that process and the tools you can use to easily automate that process.

1. Setup a Repository

Setting up a repository is fairly simple. We'll be focusing on Github for now. Simply click on the create new repository. Give it a name that matches your new app. If your app doesn't have a name yet, go with the name provided. You can always rename the repo later. If this is a open source project, then choose a license and mark it as public; otherwise choose private with no license.

Feel free to enable the README and use the Swift .gitignore file but we'll end up modifying these later anyways.

Go ahead and click create and you should see a new repo with a gitignore file (if chosen) and a README file with just the header.

Next create a new branch. I do this since I do want clutter in my commit history for steps I want to save (i.e. commit) but will never need to look at or revert to. When we are ready to save a particular step we'll use a squash commit to merge as one commit for everything we'll done. We'll get more into this in a later step.

For this tutorial I'll use the terminal but you can use whatever git app of your choosing. Let's open up the terminal and `cd` into the directory where I keep my projects. When I open up the terminal it goes to my home directory `/Users/leo` but my projects are in `/Users/leo/Documents/Projects` so I need run the command:

```
> cd Documents/Projects
```

Next copy the url of your repo by clicking on Code then choose your authentication method - I use SSH - and click the little copy symbol to the right to copy the url.

Now go back to the terminal from your _projects_ directory, type:


```
> git clone <Use CMD-V to paste the url here>
```

So if my repo is called `my-new-project` under my BrightDigit organization:

```
> git clone git@github.com:brightdigit/my-new-project.git
```

Next `checkout` the new branch you created...

```
> git checkout project-setup
```

You should be in the new branch. We are going to make one last change before moving on to the next step. Let's update our .gitignore file. It's pretty minimal at this point. Luckily the folks at toptal provide an excellent service which will help. 

You can go to [the website for their gitignore project](https://www.toptal.com/developers/gitignore) however we'll be doing this from the command line to keep it simpler. The base url for the automatically generated gitignore using their API is:

https://www.toptal.com/developers/gitignore/api/

After that simply type in a comma separated list of operating systems, programming languages, and tools which built unneeded cruft you'd wish to ignore.

In our case, we'll use ` https://www.toptal.com/developers/gitignore/api/xcode,swift,macos` to ignore Xcode, Swift, and macOS files which we don't want to commit. To save this to our repo via the terminal, we'll use:

```
> curl https://www.toptal.com/developers/gitignore/api/xcode,swift,macos > .gitignore
```

This will overwrite our current .gitignore. I would also make a few other changes:

1. `# .swiftpm` - uncomment this out
2. `*.xcworkspace/*` - add this since we'll be using a tool to create our Xcode workspaces and projects.


the next step is setting up some sort of tool for 
2. Use Mise for development tools
3. Linting Your Code
4. Package Based Development
5. Create an Xcode Project



How do I setup an Apple Watch app in React Native?
* How do I setup an XCFramework

How do I setup a github action to automate CloudKit public database updates?
