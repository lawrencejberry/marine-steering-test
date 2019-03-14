//
//  LocationService.swift
//  Marine Steering Test
//
//  Created by Lawrence Berry on 27/02/2019.
//  Copyright © 2019 Lawrence Berry. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate {
    func tracingLocation(_ currentLocation: CLLocation)
    func tracingHeading(_ currentHeading: CLHeading)
    func tracingLocationDidFailWithError(_ error: NSError)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    static let sharedInstance: LocationService = {
        let instance = LocationService()
        return instance
    }()
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var currentHeading: CLHeading?
    var delegate: LocationServiceDelegate?
    
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            // you have 2 choice
            // 1. requestAlwaysAuthorization
            // 2. requestWhenInUseAuthorization
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
        locationManager.distanceFilter = 5.0 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        
        locationManager.headingFilter = CLLocationDegrees(0.5)
        locationManager.headingOrientation = CLDeviceOrientation.landscapeLeft
        locationManager.delegate = self
    }
    
    func startUpdating() {
        print("Starting Location and Heading Updates")
        self.locationManager?.startUpdatingLocation()
        self.locationManager?.startUpdatingHeading()
    }
    
    func stopUpdating() {
        print("Stop Location and Heading Updates")
        self.locationManager?.stopUpdatingLocation()
        self.locationManager?.stopUpdatingHeading()
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        
        // singleton for get last(current) location
        currentLocation = location
        
        // use for real time update location
        updateLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        
        // singleton for get last(current) heading
        currentHeading = heading
        
        // use for real time update heading
        updateHeading(heading)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // do on error
        updateLocationDidFailWithError(error as NSError)
    }
    
    // Private function
    fileprivate func updateLocation(_ currentLocation: CLLocation){
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocation(currentLocation)
    }
    
    fileprivate func updateHeading(_ currentHeading: CLHeading){
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingHeading(currentHeading)
    }
    
    fileprivate func updateLocationDidFailWithError(_ error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error)
    }
}
