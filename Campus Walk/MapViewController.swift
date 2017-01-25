//
//  ViewController.swift
//  Campus Walk
//
//  Created by Shane Byers on 10/23/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Place: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var latitude : Double
    var longitude : Double
    
    var title: String?
    var subtitle: String?
    
    var photoName: String?
    
    var isFavorite: Bool
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, photoName: String, isFavorite: Bool) {
        self.coordinate = coordinate
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.title = title
        self.subtitle = subtitle
        if photoName == "" {
            self.photoName = "No_Image_Available.png"
        } else {
            self.photoName = photoName
        }
        self.isFavorite = isFavorite
    }
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let model = BuildingModel.sharedInstance
    
    let directionModel = DirectionModel.sharedInstance
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var directionsBar: UINavigationBar!
    
    @IBOutlet weak var prevDirectionButton: UIBarButtonItem!
    
    @IBOutlet weak var nextDirectionButton: UIBarButtonItem!
    
    @IBOutlet weak var directionLabel: UINavigationItem!
    
    @IBOutlet weak var etaBar: UINavigationBar!
    
    @IBOutlet weak var etaLabel: UINavigationItem!
    
    
    
    var places = [Place]()
    
    var newAnnotation : Place?
    
    var tableViewController = UITableViewController()
    
    var currentlyTracking = false
    
    
    let defaultIdentifier = "Default"
    let favoriteIdentifier = "Favorite"
    
    var newRegion : MKCoordinateRegion?
    
    var favoritesShown = true
    
    let zoomedInCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    
    var directionsSource : Building?
    
    var directionsDestination : Building?
    
    var currentStepInDirections = 0

    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        mapView.delegate = self
        
        places = []
        
        mapView.removeAnnotations(mapView.annotations)
        
        configureLocationManager()
        
        setRegion()
        
        if model.trackLocation {
            self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: true)
            mapView.userTrackingMode = .followWithHeading
        } else {
            mapView.userTrackingMode = .none
        }
        
        switch model.mapType {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard
        }
        
        for favorite in model.favorites() {
            
            let subtitle : String
            if favorite.yearConstructed != 0 {
                subtitle = "Constructed in \(favorite.yearConstructed)"
            } else {
                subtitle = ""
            }
            let new_place = Place(coordinate: CLLocationCoordinate2D(latitude: favorite.latitude, longitude: favorite.longitude), title: favorite.name, subtitle: subtitle, photoName: favorite.photoName, isFavorite: true)
            places.append(new_place)
            
        }
        
        for building in model.defaults() {
            let subtitle : String
            if building.yearConstructed != 0 {
                subtitle = "Constructed in \(building.yearConstructed)"
            } else {
                subtitle = ""
            }
            let new_place = Place(coordinate: CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude), title: building.name, subtitle: subtitle, photoName: building.photoName, isFavorite: false)
            places.append(new_place)
        }
        
        if model.showFavorites {
            for place in places {
                mapView.addAnnotation(place)
            }
        } else {
            for place in places {
                if !place.isFavorite {
                    mapView.addAnnotation(place)
                }
            }
        }
        
    }
    
    func preferencesSet() {
        places = []
        
        mapView.removeAnnotations(mapView.annotations)
        
        if model.trackLocation {
            self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: true)
            mapView.userTrackingMode = .followWithHeading
        } else {
            mapView.userTrackingMode = .none
        }
        
        for favorite in model.favorites() {
            
            let subtitle : String
            if favorite.yearConstructed != 0 {
                subtitle = "Constructed in \(favorite.yearConstructed)"
            } else {
                subtitle = ""
            }
            let new_place = Place(coordinate: CLLocationCoordinate2D(latitude: favorite.latitude, longitude: favorite.longitude), title: favorite.name, subtitle: subtitle, photoName: favorite.photoName, isFavorite: favorite.isFavorite)
            places.append(new_place)
            
        }
        
        if model.showFavorites {
            
            for place in places {
                mapView.addAnnotation(place)
            }
        } else {
            for place in places {
                if !place.isFavorite {
                    mapView.addAnnotation(place)
                }
            }
        }
    }
    
    func addAnnotation(_ title: String, subtitle: String, latitude: Double, longitude: Double, photoName: String, masterTableViewController: UITableViewController, defaultBuildings: [Building], favoriteBuildings: [Building]) {
        
        let annotation = Place(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), title: title, subtitle: subtitle, photoName: photoName, isFavorite: false)
        
        newAnnotation = annotation
        
        self.newRegion = MKCoordinateRegion(center: annotation.coordinate, span: zoomedInCoordinateSpan)
        
        tableViewController = masterTableViewController
        
        for building in defaultBuildings {
            let subtitle : String
            if building.yearConstructed != 0 {
                subtitle = "Constructed in \(building.yearConstructed)"
            } else {
                subtitle = ""
            }
            places.append(Place(coordinate: CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude), title: building.name, subtitle: subtitle, photoName: building.photoName, isFavorite: false))
        }
        
        for building in favoriteBuildings {
            let subtitle : String
            if building.yearConstructed != 0 {
                subtitle = "Constructed in \(building.yearConstructed)"
            } else {
                subtitle = ""
            }
            let new_place = Place(coordinate: CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude), title: building.name, subtitle: subtitle, photoName: building.photoName, isFavorite: false)
            new_place.isFavorite = true
            places.append(new_place)
        }
        
        if !places.contains(annotation) {
            places.append(annotation)
        }
    }
    
    func setRegion() {
        let center = CLLocationCoordinate2D(latitude: model.currentMapRegion.latitude, longitude: model.currentMapRegion.longitude)
        let span = MKCoordinateSpan(latitudeDelta: model.currentMapRegion.latitudeDelta, longitudeDelta: model.currentMapRegion.longitudeDelta)
        
        mapView.region = MKCoordinateRegion(center: center, span: span)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        } else {
            mapView.showsUserLocation = false
            locationManager.stopUpdatingLocation()
        }
    }

    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let view: MKAnnotationView
        if let annotation = annotation as? Place {
            
            newRegion = MKCoordinateRegion(center: annotation.coordinate, span: zoomedInCoordinateSpan)

            if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: defaultIdentifier) {
                dequedView.annotation = annotation
                view = dequedView
                return view
            } else if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: favoriteIdentifier) {
                dequedView.annotation = annotation
                view = dequedView
                return view
            }else {
                
                let pin : MKPinAnnotationView
                
                var isFavorite : Bool = false
                
                for place in places {
                    if place.title == annotation.title! {
                        if place.isFavorite {
                            isFavorite = true
                        }
                    }
                }
                
                if isFavorite {
                    pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: favoriteIdentifier)
                    pin.pinTintColor = UIColor.blue
                } else {
                    pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: defaultIdentifier)
                    pin.pinTintColor = UIColor.red
                }
                
                pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
                
                pin.canShowCallout = true
                
                return pin

            }
        }
        return nil
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if let newRegion = self.newRegion {
            UIView.animate(withDuration: 1.0, animations:{
                mapView.region = newRegion
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let annotation = view.annotation as? Place {
            let alertController = UIAlertController(title: annotation.title, message: annotation.subtitle, preferredStyle: .actionSheet)
            var isFavorite : Bool = false
            
            for place in places {
                if place.title! == annotation.title! {
                    if place.isFavorite {
                        isFavorite = true
                    } else {
                        isFavorite = false
                    }
                }
            }
            
            if model.showFavorites {
                
                if isFavorite {
                    let deleteFavoriteAction = UIAlertAction(title: "Remove from Favorites", style: .destructive, handler: { (action) in
                        self.model.deleteFavoriteBuildingFromFavoritesWithName(annotation.title!)
                        annotation.isFavorite = false
                        self.tableViewController.tableView.reloadSectionIndexTitles()
                        self.tableViewController.tableView.reloadData()
                        self.tableViewController.tableView.setContentOffset(CGPoint.zero, animated: false)
                        let pin = view as! MKPinAnnotationView
                        pin.pinTintColor = UIColor.red
                        self.model.updateCurrentLocation(self.mapView.region.center.latitude, longitude: self.mapView.region.center.longitude, latitudeDelta: self.mapView.region.span.latitudeDelta, longitudeDelta: self.mapView.region.span.longitudeDelta)
                    })
                    alertController.addAction(deleteFavoriteAction)
                } else {
                    let addFavoriteAction = UIAlertAction(title: "Add to Favorites", style: .default, handler: {(action) in
                        self.model.addFavoriteBuildingWithName(annotation.title!)
                        annotation.isFavorite = true
                        self.tableViewController.tableView.reloadSectionIndexTitles()
                        self.tableViewController.tableView.reloadData()
                        self.tableViewController.tableView.setContentOffset(CGPoint.zero, animated: false)
                        let pin = view as! MKPinAnnotationView
                        pin.pinTintColor = UIColor.blue
                        self.model.updateCurrentLocation(self.mapView.region.center.latitude, longitude: self.mapView.region.center.longitude, latitudeDelta: self.mapView.region.span.latitudeDelta, longitudeDelta: self.mapView.region.span.longitudeDelta)
                    })
                    
                    alertController.addAction(addFavoriteAction)
                }
                
            }
            
            let showDetailsAction = UIAlertAction(title: "More Information", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "showBuildingDetailsSegue", sender: view)
            })
            
            alertController.addAction(showDetailsAction)
            
            let removePinAction = UIAlertAction(title: "Remove Pin", style: .destructive, handler: { (action) in
                self.model.removeBuildingWithName(annotation.title!)
                self.places.remove(at: self.places.index(of: annotation)!)
                self.mapView.removeAnnotation(annotation)
                self.tableViewController.tableView.reloadSectionIndexTitles()
                self.tableViewController.tableView.reloadData()
                self.tableViewController.tableView.setContentOffset(CGPoint.zero, animated: false)
                self.model.updateCurrentLocation(self.mapView.region.center.latitude, longitude: self.mapView.region.center.longitude, latitudeDelta: self.mapView.region.span.latitudeDelta, longitudeDelta: self.mapView.region.span.longitudeDelta)
            })
            
            alertController.addAction(removePinAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "showBuildingDetailsSegue":
            let destinationViewController = segue.destination as! BuildingDetailsViewController
            let annotationView = sender as! MKAnnotationView
            
            let annotation = annotationView.annotation as! Place
            
            let building = model.buildingWithName(annotation.title!)!
            
            let buildingPhoto : UIImage
            
            if model.showOriginalPictures {
                if building.photoName == "" {
                    buildingPhoto = UIImage(named: model.noImagePhotoName)!
                } else {
                    buildingPhoto = UIImage(named: building.photoName)!
                }
            } else {
                if building.updatedImage != nil {
                    buildingPhoto = building.updatedImage!
                } else if building.photoName != "" {
                    buildingPhoto = UIImage(named: building.photoName)!
                } else {
                    buildingPhoto = UIImage(named: model.noImagePhotoName)!
                }
            }
            
            destinationViewController.configureWithBuildigName(annotation.title!, constructedInYear: annotation.subtitle!, withImage: buildingPhoto)
        case "getDirectionsSegue":
            break
        case "showDirectionsInstructionsSegue":
            break
        case "showPreferencesSegue":
            break
        default:
            assert(false, "Unhandled Segue")
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let region = mapView.region
        model.updateCurrentLocation(region.center.latitude, longitude: region.center.longitude, latitudeDelta: region.span.latitudeDelta, longitudeDelta: region.span.longitudeDelta)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 3.0
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }

    
    func sourceAndDestination(_ source: Building?, destination: Building?) {
        self.directionsSource = source
        self.directionsDestination = destination
    }
    
    func getDirections() {
        let walkingRouteRequest = MKDirectionsRequest()
        
        let sourcePlacemark : MKPlacemark
        
        if let source = directionsSource {
            sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (source.latitude), longitude: (source.longitude)), addressDictionary: nil)
        } else {
            sourcePlacemark = MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil)
        }
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        sourceMapItem.name = directionsSource?.name
        
        let destinationPlacemark : MKPlacemark
        
        if let destination = directionsDestination {
            destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude), addressDictionary: nil)
        } else {
            destinationPlacemark = MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil)
        }
        
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = directionsDestination?.name
        
        walkingRouteRequest.source = sourceMapItem
        walkingRouteRequest.destination = destinationMapItem
        walkingRouteRequest.transportType = .walking
        walkingRouteRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: walkingRouteRequest)
        directions.calculate { (response, error) in
            if error != nil {
                assert(false, "Error getting directions.")
            } else {
                self.showDirections(response!)
            }
        }
    }
    
    func showDirections(_ response: MKDirectionsResponse) {
        mapView.removeOverlays(mapView.overlays)
        
        let route = response.routes.first!
        
        directionModel.updateInstructionsList(route.steps.map({$0.instructions}))
        
        let travelTime = route.expectedTravelTime
        
        let currentDate = Date().addingTimeInterval(travelTime)
        
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone.current
        
        formatter.dateFormat = "h:mm a"
        
        let eta = formatter.string(from: currentDate)
        
        etaLabel.title = "ETA: \(eta)"
        
        mapView.add(route.polyline)
        
        let region = MKCoordinateRegionMakeWithDistance(route.polyline.coordinate, 1500, 1500)
        mapView.setRegion(region, animated: true)
        directionLabel.title = directionModel.instructionsAtIndex(0)
        directionsBar.isHidden = false
        etaBar.isHidden = false
    }

    
    @IBAction func dismissDirections(_ segue: UIStoryboardSegue) {
        getDirections()
    }
    
    @IBAction func dismissBuildingDetails(_ segue: UIStoryboardSegue) {
        tableViewController.tableView.reloadData()
    }
    
    @IBAction func dismissPreferences(_ segue: UIStoryboardSegue) {
        viewDidLoad()
    }
    
    @IBAction func prevDirectionButtonPressed(_ sender: UIBarButtonItem) {
        currentStepInDirections -= 1
        
        if currentStepInDirections == 0 {
            prevDirectionButton.isEnabled = false
        }
        
        nextDirectionButton.isEnabled = true
        
        directionLabel.title = directionModel.instructionsAtIndex(currentStepInDirections)
    }
    
    @IBAction func nextDirectionButtonPressed(_ sender: UIBarButtonItem) {
        currentStepInDirections += 1
        
        if currentStepInDirections == directionModel.numberOfInstructions() - 1 {
            nextDirectionButton.isEnabled = false
        }
        
        prevDirectionButton.isEnabled = true
        
        directionLabel.title = directionModel.instructionsAtIndex(currentStepInDirections)
    }

    @IBAction func removeRouteButtonPressed(_ sender: UIBarButtonItem) {
        mapView.removeOverlays(mapView.overlays)
        directionsBar.isHidden = true
        etaBar.isHidden = true
    }

}
