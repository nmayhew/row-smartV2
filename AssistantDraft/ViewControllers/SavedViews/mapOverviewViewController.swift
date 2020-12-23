//
//  mapOverviewViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 17/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit
import MapKit

/*One of the page views within SaveSessionsDetails.
 * It shows the map with a line of the route taken,
 * plus annotations where pieces started and ended
 */

class mapOverviewViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    private var region: MKCoordinateRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(newLocations), name: NSNotification.Name(rawValue: "savedLocationSent"), object: nil)
        notification.addObserver(self
            , selector: #selector(ftLtLocations), name: NSNotification.Name(rawValue: "firstLastLocations"), object: nil)
    }
    
    //Called when first and last pieces locations received.
    @objc func ftLtLocations(notification: NSNotification) {
        if let firstLastLocations = notification.userInfo?["firLastlocations"] as? [Location] {
            pieceOverlay(locationList: firstLastLocations)
        }
    }
    
    //Called when locations received
    @objc func newLocations(notification: NSNotification) {
        if let locationsTemp = notification.userInfo?["locations"] as? [Location] {
            loadMap(locationsArr: locationsTemp)
        }
    }
    
    //Sets mapRegion
    private func mapRegion(locationsArr: [Location]) -> MKCoordinateRegion? {
        guard
            locationsArr.count > 0
            else {
                return nil
        }
        let latitudes = locationsArr.map { location -> Double in
            return location.latitude
        }
        
        let longitudes = locationsArr.map { location -> Double in
            return location.longitude
        }
        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLong = longitudes.max()!
        let minLong = longitudes.min()!
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.75,
                                    longitudeDelta: (maxLong - minLong) * 1.75)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    //Loading Map, error message if no locations, then sets map region and puts overlay (route taken)
    private func loadMap(locationsArr: [Location]) {
        guard locationsArr.count > 0,
            let regionTemp = mapRegion(locationsArr: locationsArr)
            else {
                let alert = UIAlertController(title: "Error",
                                              message: "Sorry, this training session has no locations saved",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(alert, animated: true)
                return
        }
        
        region = regionTemp
        mapView.setRegion(region!, animated: true)
        overlayCreator(locationsArr: locationsArr)
    }
    
    //Creates line between GPS locations (route of training session)
    private func overlayCreator(locationsArr: [Location]) {
        for index in stride(from: 0, to: locationsArr.count - 2, by: 1) {
            let coordinateOne = CLLocationCoordinate2D(latitude: locationsArr[index].latitude, longitude: locationsArr[index].longitude)
            let coordinateTwo = CLLocationCoordinate2D(latitude: locationsArr[index+1].latitude, longitude: locationsArr[index+1].longitude)
            mapView.addOverlay(MKPolyline(coordinates: [coordinateOne,coordinateTwo], count: 2))
        }
    }
    
    //Overlays map with markers for start and end of pieces
    func pieceOverlay(locationList: [Location]) {
        var count = 0
        var pieceNumber = 1
        for locationPiece in locationList {
            if (locationPiece.longitude == 0.0 && locationPiece.latitude == 0.0) {
                //So piece number stay aligned
                CoreDataStack.context.delete(locationPiece)// so doesn't continue to exist
                if (count % 2 == 1) {
                    pieceNumber = pieceNumber + 1
                }
            } else if (count % 2 == 1) {
                //Start
                let marker = MyAnnotation(title: "Start" , subtitle: "Start of piece \(pieceNumber)", coordinate: CLLocationCoordinate2D(latitude: locationPiece.latitude, longitude: locationPiece.longitude))
                marker.image = UIImage(named: "Start")
                
                mapView.addAnnotation(marker)
                pieceNumber = pieceNumber + 1
            } else {
                //Stop
                let marker = MyAnnotation(title: "End", subtitle: "End of piece \(pieceNumber)", coordinate: CLLocationCoordinate2D(latitude: locationPiece.latitude, longitude: locationPiece.longitude))
                marker.image = UIImage(named: "Stop")
                mapView.addAnnotation(marker)
                
            }
            count = count + 1
        }
    }
    
    //MARK: mapView delegates
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil;
        } else if let annotation = annotation as? MyAnnotation {
            let identifier = "identifier"
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.image = annotation.image
            annotationView.canShowCallout = true
            annotationView.calloutOffset = CGPoint(x: -5, y: 5)
            return annotationView
        } else {
            //Should never run
            let pinIdent = "Pin";
            var pinView: MKPinAnnotationView;
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdent) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation;
                pinView = dequeuedView;
            } else {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdent);
                
            }
            return pinView;
        }
    }
}



