//
//  AppDelegate.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 2/12/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit
import StoreKit
import SafariServices

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingDelegate {

    var window: UIWindow?
    
    //var authenticationDone = false
    
    var auth: SPTAuth?
    var authViewController: UIViewController?
    var player: SPTAudioStreamingController?
    var session: SPTSession?
    let kClientId = "5359d81b33be4967b97002d3b2779cb2"
    let kCallbackURL = "final-universal-music-project://callback"
    let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenRefreshServiceURL = "http://localhost:1234/refresh"
    let kSessionUserDefaultsKey = "Spotify Session"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.auth = SPTAuth.defaultInstance()
        self.player = SPTAudioStreamingController.sharedInstance()
        self.auth?.session = SPTSession()
        
        self.auth?.clientID = kClientId
        self.auth?.redirectURL = URL(string: kCallbackURL)
        self.auth?.requestedScopes = [SPTAuthPlaylistReadCollaborativeScope, SPTAuthPlaylistReadPrivateScope, SPTAuthStreamingScope]
        self.auth?.sessionUserDefaultsKey = kSessionUserDefaultsKey
        
        player?.delegate = self
        do {
            try player?.start(withClientId: auth?.clientID)
        } catch _ {
            
        }
        
        DispatchQueue.main.async {
            self.startAuthenticationFlow()
        }
        
        return true
    }
    
    func startAuthenticationFlow() {
        print("\(self.auth?.session)")
        if (self.auth?.session.isValid())! == true {
            player?.login(withAccessToken: SPTAuth.defaultInstance().session.accessToken)
        }
        else {
            let authURL = auth?.spotifyWebAuthenticationURL()
            self.authViewController = SFSafariViewController(url: authURL!)
            self.window?.rootViewController?.present(self.authViewController!, animated: true, completion: nil)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        appleMusicRequestPermission()
        appleMusicCheckIfDeviceCanPlayback()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if (self.auth?.canHandle(url))! {
            // Close the authentication window
            self.authViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            // Parse the incoming url to a session object
            self.auth?.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                if ((session) != nil) {
                    // login to the player
                    self.player?.login(withAccessToken: self.auth?.session.accessToken)
                }
            })
            //authenticationDone = true
            return true
        }
        return false
    }
    
    func appleMusicRequestPermission() {
        print("I got here")
        switch SKCloudServiceController.authorizationStatus() {
            
        case .authorized:
            print("The user's already authorized - we don't need to do anything more here, so we'll exit early.")
            return
        case .denied:
            print("The user has selected 'Don't Allow' in the past - so we're going to show them a different dialog to push them through to their Settings page and change their mind, and exit the function early.")
            // Show an alert to guide users into the Settings
            return
        case .notDetermined:
            print("The user hasn't decided yet - so we'll break out of the switch and ask them.")
            break
        case .restricted:
            print("User may be restricted; for example, if the device is in Education mode, it limits external Apple Music usage. This is similar behaviour to Denied.")
            return
            
        }
        
        // request authorization if the user hasn't determined to authorize Apple Music
        SKCloudServiceController.requestAuthorization { (status:SKCloudServiceAuthorizationStatus) in
            switch status {
            case .authorized:
                print("All good - the user tapped 'OK', so you're clear to move forward and start playing.")
            case .denied:
                print("The user tapped 'Don't allow'. Read on about that below...")
            case .notDetermined:
                print("The user hasn't decided or it's not clear whether they've confirmed or denied.")
            default:
                break
            }
            
        }
        
    }
    
    func appleMusicCheckIfDeviceCanPlayback() {
        let serviceController = SKCloudServiceController()
        serviceController.requestCapabilities {
            (capability:SKCloudServiceCapability, err:Error?) -> Void in
            
            switch capability {
            case SKCloudServiceCapability.musicCatalogPlayback:
                print("The user has an Apple Music subscription and can playback music!")
            case SKCloudServiceCapability.addToCloudMusicLibrary:
                print("The user has an Apple Music subscription, can playback music AND can add to the Cloud Music Library")
            default:
                print("The user doesn't have an Apple Music subscription available. Now would be a good time to prompt them to buy one?")
                break
            }
        }
    }


}

