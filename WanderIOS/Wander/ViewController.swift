//
//  ViewController.swift
//  Wander
//
//  Created by Shahbaz on 2019-09-14.
//  Copyright © 2019 Shahbaz Momi. All rights reserved.
//

import ARKit_CoreLocation
import CoreLocation
import UIKit
import FirebaseUI
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, FUIAuthDelegate {
    
    @IBOutlet var subView: UIView!
    let sceneView = SceneLocationView()
    
    override func viewWillAppear(_ animated: Bool) {
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user == nil) {
                // attempt sign in
                self.beginSignIn()
            } else {
                self.hasAuth(user!)
            }
        }
    }
    
    func beginSignIn() {
        // firebase ui
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIFacebookAuth()
        ];
        authUI?.providers = providers
        
        let authViewController = authUI?.authViewController()
        if(authViewController != nil) {
            present(authViewController!, animated: true, completion: nil)
        }

    }
    
    func hasAuth(_ u: User) {
        print(AccessToken.current?.tokenString)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subView.addSubview(sceneView)
    
        sceneView.orientToTrueNorth = true
        sceneView.run()

        // lat: 43.472806, lon: -80.539641
        let coord = CLLocationCoordinate2D(latitude: 43.472806, longitude: -80.539641)
        let loc = CLLocation(coordinate: coord, altitude: 329)
        
        let v = EventView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        let annotation = LocationAnnotationNode(location: loc, view: v)
        
        sceneView.showAxesNode = true
//        test this
//        annotation.scaleRelativeToDistance = true
        sceneView.addLocationNodeWithConfirmedLocation(locationNode: annotation)
        
        
    }

    @IBAction func resetNorth(_ sender: Any) {
        // need to get current heading to set as north
    }
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            beginSignIn()
        } catch {
        
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.frame = subView.bounds
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if(authDataResult != nil) {
            hasAuth(authDataResult!.user)
        }
    }
}

