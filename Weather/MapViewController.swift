//
//  MapViewController.swift
//  Weather
//
//  Created by Aman Bhullar on 2017-11-09.
//  Copyright © 2017 Aman Bhullar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate : class {
    func addItemViewControllerDidComplete (_ controller : MapViewController, item : WeatherDTO)
    
 
    
}

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {

    var weatherDTO = WeatherDTO()
    
    var newWeatherDTO = WeatherDTO()

    weak var delegate : MapViewControllerDelegate?
    
    
 
    @IBOutlet weak var done: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var myMap: MKMapView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        let geocoder = CLGeocoder()
//        var address = "Toronto"
        geocoder.geocodeAddressString(weatherDTO.address) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lang = placemark?.location?.coordinate.longitude
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat!, lang! )
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            self.myMap.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = self.weatherDTO.address
//            annotation.subtitle = "Rent here"
            self.myMap.addAnnotation(annotation)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Cancel(_ sender: Any) {
        print("Cancel")
        delegate?.addItemViewControllerDidComplete(self, item: weatherDTO)
    }
    
    @IBAction func Done(_ sender: Any) {
        delegate?.addItemViewControllerDidComplete(self, item: newWeatherDTO)
    }
    
    func searchBarSearchButtonClicked(_: UISearchBar){
        
        print (searchBar.text!)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchBar.text!) {
            placemarks, error in
            
            if error != nil {
                print("Reverse geocoder failed with error \( error?.localizedDescription)" )
                return
            }
            self.done.isEnabled = true
            self.newWeatherDTO.address = self.searchBar.text!
            
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lang = placemark?.location?.coordinate.longitude
            self.newWeatherDTO.latitude = lat!
            self.newWeatherDTO.longitude = lang!
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat!, lang! )
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            self.myMap.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = self.weatherDTO.address
            //            annotation.subtitle = "Rent here"
            self.myMap.addAnnotation(annotation)
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
