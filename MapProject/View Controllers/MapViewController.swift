//
//  MapViewController.swift
//  MapProject
//
//  Created by Xcode User on 2020-10-07.
//  Copyright © 2020 Xcode User. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
class MapViewController: UIViewController,UITextFieldDelegate, MKMapViewDelegate,UITableViewDataSource, UITableViewDelegate {
    
    let locationManager = CLLocationManager()
    
    
    @IBOutlet var myMapView : MKMapView!
    @IBOutlet var tbLocEntered : UITextField!
    @IBOutlet var myTableView : UITableView!
    @IBOutlet var tbWaypoint1: UITextField!
    @IBOutlet var tbWaypoint2: UITextField!
    @IBOutlet var segment: UISegmentedControl!
    
   
    
    var routeSteps = ["Enter a Destination to see the steps"]
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

    let regionRadius: CLLocationDistance = 20000
    
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius , longitudinalMeters: regionRadius)
        myMapView.setRegion(coordinateRegion, animated: true )
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        var initialLocation = CLLocation(latitude: 43.655787, longitude: -79.739534)
//        centerMapOnLocation(location: initialLocation)
//        let dropPin = MKPointAnnotation()
//        dropPin.coordinate = initialLocation.coordinate
//        dropPin.title = "Starting at sheridan college"
//        self.myMapView.addAnnotation(dropPin)
//        self.myMapView.selectAnnotation(dropPin, animated: true)
        
        
        let coordinate = CLLocationCoordinate2DMake(43.655787, -79.739534)
        self.myMapView.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = coordinate
        dropPin.title = "Starting at sheridan college"
        self.myMapView.addAnnotation(dropPin)
        self.myMapView.selectAnnotation(dropPin, animated: true)
        
        
        let circle = MKCircle(center: coordinate, radius: 2000)
        self.myMapView.addOverlay(circle)

        
    
        
    }
    
   
    
    func addressToCordinates(address: String, completion: @escaping (Bool, CLLocationCoordinate2D?) -> () )
        {
            var newLocation: CLLocation!
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address, completionHandler: {(placemake,error)-> Void in
                if error != nil {
                    print(error?.localizedDescription)
                    completion(false,nil)
                } else {
                    if placemake!.count > 0 {
                        let placemark = placemake![0] as CLPlacemark
                        let location = placemark.location
                        
                        completion(true, location?.coordinate)
                        
                    }
                }
            })
           
        }
    
    
    func location(StartPoint: CLLocation,DestinationAddress: String){
        let geocoder = CLGeocoder()
        
       // let InitialAddress = addressToCordinates(Address: InitialAddress)
        
        geocoder.geocodeAddressString(DestinationAddress, completionHandler:
            {(placemaks, error) -> Void in
                if(error != nil){
                    print("Error", error)
                }
                
                if let placemark = placemaks?.first{
                    let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                    
                    let newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    
                    print("new location \(newLocation)")
                    self.centerMapOnLocation(location: newLocation)
                    let dropPin = MKPointAnnotation()
                    dropPin.coordinate = coordinates
                    dropPin.title = placemark.name
                    self.myMapView.addAnnotation(dropPin)
                    self.myMapView.selectAnnotation(dropPin, animated: true)
                    
                    
                    
                    let request = MKDirections.Request()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: StartPoint.coordinate, addressDictionary: nil))
                    
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: nil))
                    
                    request.requestsAlternateRoutes = false
                    request.transportType = .automobile
                    
                    let directions = MKDirections(request: request)
                    directions.calculate(completionHandler: {
                        [unowned self] response, error in
                        
                        for route in (response?.routes)!
                        {
                            
                            print(route.polyline.boundingMapRect.height)
                            print(route.polyline.boundingMapRect.width)
                            
                            if(route.polyline.boundingMapRect.height > 20000 || route.polyline.boundingMapRect.width > 20000)
                            {
                                let alert = UIAlertController(title: "OutSide of bounding box", message: "", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            else{
                                let alert = UIAlertController(title: "Inside of bounding box", message: "", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            self.myMapView.addOverlay(route.polyline,level:MKOverlayLevel.aboveRoads)
                            self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                            
                            self.routeSteps.removeAll( )
                            for step in route.steps{
                                self.routeSteps.append(step.instructions)
                                self.myTableView.reloadData()
                            }
                        }
                    })
                }
        }
        )
        
        return
    }
    
    
    @IBAction func findNewLocation(){
//        var addresses = ["Brampton","Toronto","Montreal"]
        let locEnteredText = tbLocEntered.text
        let Waypoint1 = tbWaypoint1.text
        let Waypoint2 = tbWaypoint2.text
        
        
         var initialLocation = CLLocation(latitude: 43.655787, longitude: -79.739534)
        location(StartPoint: initialLocation, DestinationAddress: locEnteredText!)
    }
    
    @IBAction func changeLoc(sender: UISegmentedControl)
    {
        let locEnteredText = tbLocEntered.text
        let Waypoint1 = tbWaypoint1.text
        let Waypoint2 = tbWaypoint2.text
        
        switch sender.selectedSegmentIndex {
        case 1:
            do {
                self.addressToCordinates(address: locEnteredText!, completion: {
                    success, coordinate in
                    
                    if success {
                        let lat = coordinate?.latitude
                        let long = coordinate?.longitude
                        print("Lat: \(lat) LONG: \(long)")
                        var initialLocation = CLLocation(latitude: lat!, longitude: long!)
                        self.location(StartPoint: initialLocation, DestinationAddress: Waypoint1!)
                    } else {
                        let alert = UIAlertController(title: "Enter Valid Address", message: "", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        case 2:
            do {
                self.addressToCordinates(address: Waypoint1!, completion: {
                    success, coordinate in
                    
                    if success {
                        let lat = coordinate?.latitude
                        let long = coordinate?.longitude
                        print("Lat: \(lat) LONG: \(long)")
                        var initialLocation = CLLocation(latitude: lat!, longitude: long!)
                        self.location(StartPoint: initialLocation, DestinationAddress: Waypoint2!)
                    } else {
                        let alert = UIAlertController(title: "Enter Valid Address", message: "", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        default:
            do {
                var initialLocation = CLLocation(latitude: 43.655787, longitude: -79.739534)
                location(StartPoint: initialLocation, DestinationAddress: locEnteredText!)
                
            }
        }
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
//            let polygon = MKPolygonRenderer(polygon: overlay as! MKPolygon)
//            polygon.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
//            polygon.lineWidth = 1
//            polygon.strokeColor = UIColor.red
            
            
            
            let circle = MKCircleRenderer(circle: overlay as! MKCircle)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
            return renderer
            
        }
        
//        let circleRenderer = MKCircleRenderer(overlay: overlay)
//        circleRenderer.strokeColor = UIColor.red
//        circleRenderer.lineWidth = 1.0
//        return circleRenderer
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeSteps.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell =  tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        tableCell.textLabel?.text = routeSteps[indexPath.row]
        
        return tableCell
 
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
