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
import SpriteKit

class ViewController: UIViewController, FUIAuthDelegate {
    
    @IBOutlet var subView: UIView!
    let sceneView = SceneLocationView()
    @IBOutlet var buttonsBlurView: UIVisualEffectView!
        
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
    
    
    private var hasAuth: AccessToken? = nil
    func hasAuth(_ u: User) {
        guard let token = AccessToken.current else {
            return
        }

        hasAuth = token
    }
    
    var altitude = 300.0
    private func makeLocationNode(_ e: FBEvent) {
        // lat: 43.472806, lon: -80.539641
        let coord = CLLocationCoordinate2D(latitude: e.location.lat, longitude: e.location.long)
        let loc = CLLocation(coordinate: coord, altitude: altitude)
        
        let v = EventView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        v.consume(e)
        
        let annotation = LocationAnnotationNode(location: loc, view: v)

        //        test this
        //        annotation.scaleRelativeToDistance = true

        // add a name for later identification
        annotation.annotationNode.name = e.id
        
        sceneView.addLocationNodeWithConfirmedLocation(locationNode: annotation)
    }
    
    private func makeLocationNode(_ e: FBPlace) {
        // lat: 43.472806, lon: -80.539641
        let coord = CLLocationCoordinate2D(latitude: e.location.lat, longitude: e.location.lng)
        let loc = CLLocation(coordinate: coord, altitude: altitude)
        
        let v = EventView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        v.consume(e)
        
        let annotation = LocationAnnotationNode(location: loc, view: v)

        //        test this
        //        annotation.scaleRelativeToDistance = true

        // add a name for later identification
//        annotation.annotationNode.name = e.id
        
        sceneView.addLocationNodeWithConfirmedLocation(locationNode: annotation)
    }
    

    
    private func setRealtimeData(_ objs: [FBEvent]) {
        sceneView.removeAllNodes()
        
        altitude = 300.0
        for o in objs {
            makeLocationNode(o)
            altitude += 60.0
        }
    }
    
    private func setRecommendations(_ objs: [FBPlace]) {
        sceneView.removeAllNodes()
        
        altitude = 300.0
        for o in objs {
            makeLocationNode(o)
            altitude += 60.0
        }
    }
    
    private var handle: Timer? = nil
    func beginWatch(_ isRecommendedMode : Bool) {
        handle?.invalidate()
        
        handle = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {_ in
            
            guard let token = self.hasAuth else {return}
            guard let loc = self.sceneView.sceneLocationManager.bestLocationEstimate else {return}
            
            self.handle?.invalidate()
            
            print(isRecommendedMode)
            if(!isRecommendedMode) {
                DataManager.shared.doGet(token, loc.location) { objs in
                    guard let o = objs else {return}
                    self.setRealtimeData(o)
                }
            } else {
                // TODO: recommended mode
                DataManager.shared.doRecommendationsGet(token) { objs in
                    guard let o = objs else {return}
                    self.setRecommendations(o)
                }
            }
            
        })
        
        handle?.fire()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonsBlurView.layer.cornerRadius = 16.0
        buttonsBlurView.clipsToBounds = true
        
        subView.addSubview(sceneView)
    
        sceneView.orientToTrueNorth = true
        sceneView.run()
        
        sceneView.showAxesNode = true
        
        beginWatch(false) // false by default
        
        DataManager.shared.onSelectedCategory = { s in
            self.beginWatch(true)
        }
        DataManager.shared.prefetch()
    }

    @IBAction func resetNorth(_ sender: Any) {
        // need to get current heading to set as north
        guard let heading = sceneView.sceneLocationManager.locationManager.heading else {return}
        sceneView.sceneNode?.eulerAngles.y = Float(heading)
    }
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            beginSignIn()
        } catch {
        
        }
    }
    
    @IBAction func recommendedSwitchChange(sender: UISwitch) {
        handleDatasetChanged(sender.isOn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.frame = subView.bounds
    }
    
    func handleDatasetChanged(_ useRecommended : Bool) {
        buttonsBlurView.isHidden = !useRecommended
        
        beginWatch(useRecommended)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if(authDataResult != nil) {
            hasAuth(authDataResult!.user)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let results = sceneView.hitTest(touches.first!.location(in: sceneView), options: nil)
        guard let result = results.first else {return}
        if(result.node.name == nil) {
            return
        }
        let event = DataManager.shared.realtimeEvents.first(where: { e in
            e.id == result.node.name
        })
        if event == nil {
            return
        }
        performSegue(withIdentifier: "showPopup", sender: event)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DetailViewController {
            let vc = segue.destination as! DetailViewController
            vc.event = sender as? FBEvent
        }
    }
}

