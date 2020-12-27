//
//  sessionDetails.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 02/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit
import MapKit

//Produces MKmapview
class sessionDetails: UIViewController {

    //Contains Map view that shows GPS data 
    @IBOutlet weak var mapView: MKMapView!
    private let MAPSPAN: CLLocationDistance = 750
    private var first: Bool = true
    private var prevLocation: CLLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //Sets up observer to listen for locations post and new heading sent post.
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(locationRecieved), name: NSNotification.Name(rawValue: "locationSent"), object: nil)
        //nc.addObserver(self
           // , selector: #selector(headingReceived
            //), name: NSNotification.Name(rawValue: "headingSent"), object: nil)
        first = true
        
        mapView.isUserInteractionEnabled = false
       
        let initialView = MKCoordinateRegion(center: mapView!.userLocation.coordinate, latitudinalMeters: MAPSPAN, longitudinalMeters: MAPSPAN)
        mapView.setRegion(initialView, animated: true)
        mapView.showsUserLocation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print(mapView!.userLocation.coordinate)
        mapView.showsUserLocation = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.showsUserLocation = false
    }

    
    //Handles notification for new location
    @objc func locationRecieved(notification: NSNotification) {
        if let locations = notification.userInfo?["locations"] as? [CLLocation] {
            if(first) {
                //Create map
                createMap(locationList: locations)
                first = false
                prevLocation = locations.last!
            } else {
                updateMap(lastLocation: prevLocation!, newLocation: locations.last!)
                prevLocation = locations.last!
            }
            
        }
    }
    
    //Creates whole map when needed (e.g. reloading view controller
    func createMap(locationList: [CLLocation]) {
        for index in 0..<locationList.count-1 {
            let coordinates = [locationList[index].coordinate, locationList[index+1].coordinate]
            mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
        }
        let region = MKCoordinateRegion.init(center: locationList.last!.coordinate, latitudinalMeters: MAPSPAN, longitudinalMeters: MAPSPAN)
        mapView.setRegion(region, animated: true)
    }
    
    //Updates map to look at correct region and produce new line
    func updateMap(lastLocation: CLLocation, newLocation: CLLocation){
        let coordinates = [lastLocation.coordinate, newLocation.coordinate]
        mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
        let region = MKCoordinateRegion.init(center: newLocation.coordinate, latitudinalMeters: MAPSPAN, longitudinalMeters: MAPSPAN)
        mapView.setRegion(region, animated: true)
        
    }
}

//Delegate added as extension after
extension sessionDetails: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        return renderer
    }
}
