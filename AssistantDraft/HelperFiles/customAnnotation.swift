//
//  annotationExtension.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 19/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import MapKit

//My annotation used for stop and start of pieces on maps of saved training sessions 
class MyAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    var image: UIImage? = nil
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
    }
}
