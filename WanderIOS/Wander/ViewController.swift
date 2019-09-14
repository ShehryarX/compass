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

class ViewController: UIViewController {

    private let sceneView = SceneLocationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.run()
        view.addSubview(sceneView)
        
        sceneView.orientToTrueNorth = true
        
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.frame = view.bounds
    }

}

