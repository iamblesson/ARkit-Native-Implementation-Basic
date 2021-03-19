//
//  ViewController.swift
//  FIRSTARApp
//
//  Created by macUser on 17/03/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //Implement tapGestureRecognizer to interact with the scene.
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(myUIImageViewTapped(_:)))
                singleTap.numberOfTapsRequired = 1
                singleTap.numberOfTouchesRequired = 1
                self.sceneView.addGestureRecognizer(singleTap)
                self.sceneView.isUserInteractionEnabled = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
    }
    
    
    //Once we have the position, lets add the 3D model to the position
    func addIemToPosition(_ position: SCNVector3){
        guard let url = Bundle.main.url(forResource: "fender_stratocaster",
                                        withExtension: "usdz",
                                        subdirectory: "art.scnassets") else {return}
        let scene = try! SCNScene(url: url, options: [.checkConsistency : true])
        DispatchQueue.main.async {
            if let node = scene.rootNode.childNode(withName: "fender_stratocaster", recursively: false){
                node.position = position
                self.sceneView.scene.rootNode.addChildNode(node)
            }
        }
    }
        
    @objc func myUIImageViewTapped(_ recognizer: UITapGestureRecognizer) {
        
        //if(recognizer.state == UIGestureRecognizer.State.ended){
            print("myUIImageView has been tapped by the user.")
            let sceneViewTappedOn = recognizer.view as! ARSCNView
            let touchCoordinates = recognizer.location(in: sceneViewTappedOn)
            let query: ARRaycastQuery? = sceneView.raycastQuery(from: touchCoordinates, allowing: .existingPlaneInfinite, alignment: .horizontal)
            let results = sceneView.session.raycast(query!)

        
            guard !results.isEmpty, let hitTestResult = results.first else {
               print("No surface found")
               return
            }
            
            
        let position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
                                  hitTestResult.worldTransform.columns.3.y,
                                  hitTestResult.worldTransform.columns.3.z)
            
            //print(position);
            addIemToPosition(position)
 
        }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //Enable horizontal plane detection and to visualise the plane detection
        // add ARSCNDebugOptions.showFeaturePoints value to scene views debugOptions
        configuration.planeDetection = .horizontal

        //Show Feature Points
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
      
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    

    // MARK: - ARSCNViewDelegate
    
    // ARKit calls this delegate method automatically whenever it detects a new horizontal plane and also adds a new node for it.
    //To help us visualize the plane being tracked by ARKit.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //Process only anchors of type ARPlaneAnchor since we're only interested in detecting planes
        if let planeAnchor = anchor as? ARPlaneAnchor{
            //to visualize the detected planes use a SCNPlane Object
            //ARPlaneAnchor extent property provides the size of the detected plane
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.75)
            
            
            //Create SCNNode with plane geometry
            let planeNode = SCNNode(geometry: plane)
            //Node's position is matched to the anchor position to give an accurate visual
            planeNode.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.x, planeAnchor.center.z)
            // SCNPlane is one-sided and appears perpendicular to the surface by default,
            // so rotate the planeNode 90 degrees counter clockwise to make it display correctly.
            planeNode.eulerAngles.x = -.pi/2
            
            node.addChildNode(planeNode)
        }
    }
    
    //ARKit monitors the environment and updates the previously detected anchors.
    //To get these updates implement the following delegate method.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor,
           let planeNode = node.childNodes.first,
           let plane = planeNode.geometry as? SCNPlane{
            plane.width = CGFloat(planeAnchor.extent.x)
            plane.height = CGFloat(planeAnchor.extent.z)
            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        }
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

}
