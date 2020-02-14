//
//  ViewController.swift
//  ChicagoLandmarks
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet var viewDetail: UIView!
    @IBOutlet var mapView: MKMapView!{
        didSet { mapView.delegate = self }
    }
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelDescription: UILabel!
    @IBOutlet var buttonFavoriteStatus: UIButton!
    @IBOutlet var buttonFavorites: UIButton!
    
    var showingPlace:Place?
    var favoritesList:[String] = []
    var places:[Place] = []
    var zoomSpan:MKCoordinateSpan?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
        viewDetail.isHidden = true
        
        showAllPoints()
        
        // Set a center point
        let regionArray = DataManager.sharedInstance.loadRegionFromPlist()
        let zoomLocation = CLLocationCoordinate2DMake((regionArray[0] as! Double),(regionArray[1] as! Double))
        zoomSpan = MKCoordinateSpan.init(latitudeDelta: regionArray[2] as! Double, longitudeDelta: regionArray[3] as! Double)
        // Creat the region we want to see
        let viewRegion = MKCoordinateRegion.init(center: zoomLocation, span: zoomSpan!)
        // Set the initial region on the map
        mapView.setRegion(viewRegion, animated: true)
    }
    
    func showAllPoints() {
        places = DataManager.sharedInstance.loadAnnotationFromPlist()
        mapView.showAnnotations(places, animated: true)
    }
    
    @IBAction func toggleStar(_ sender: Any) {
        if buttonFavoriteStatus.isSelected {
            buttonFavoriteStatus.isSelected = false
            DataManager.sharedInstance.deleteFavorite(favorite: showingPlace!.name!)
        }else{
            buttonFavoriteStatus.isSelected = true
            DataManager.sharedInstance.saveFavorite(favorite: showingPlace!.name!)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavarites" {
            let vc = segue.destination as! FavoritesViewController
            vc.delegate = self
        }
    }
    
}

extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if (view.annotation as? Place) != nil {
            viewDetail.isHidden = false
            let place = view.annotation as! Place
            showingPlace = place
            favoritesList = DataManager.sharedInstance.listFavorites()
            labelTitle.text = place.name
            labelDescription.text = place.longDescription
            if favoritesList.contains(place.name!) {
                buttonFavoriteStatus.isSelected = true
            }else{
                buttonFavoriteStatus.isSelected = false
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Place {
            let identifier = "CustomPin"
            
            // Create a new view
            var view: PlaceMarkerView
            
            // Deque an annotation view or create a new one
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlaceMarkerView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = PlaceMarkerView(annotation: annotation, reuseIdentifier: identifier)
            }
            return view
        }
        return nil
    }
}

extension MapViewController: PlacesFavoritesDelegate {
    func favoritePlace(name: String) {
        print(name)
        for place in places {
            if place.name == name {
                let viewRegion = MKCoordinateRegion.init(center: place.coordinate, span: zoomSpan!)
                mapView.setRegion(viewRegion, animated: true)
                mapView.selectAnnotation(place, animated: true)
            }
        }
    }
}

