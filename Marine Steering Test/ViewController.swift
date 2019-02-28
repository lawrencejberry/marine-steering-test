//
//  ViewController.swift
//  Marine Steering Test
//
//  Created by Lawrence Berry on 26/02/2019.
//  Copyright © 2019 Lawrence Berry. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, LocationServiceDelegate, UITextFieldDelegate {
    
    var location_file_URL : URL!
    var heading_file_URL : URL!
    var rudder_file_URL : URL!
    var command_file_URL : URL!
    let time_formatter = DateFormatter()
    
    var rudder_angle = 0.0
    
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var fileTextField: UITextField!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var rudderAngleSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make the ViewController a LocationService delegate
        LocationService.sharedInstance.delegate = self
        self.fileTextField.delegate = self
        time_formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func textFieldShouldReturn(_ fileTextField: UITextField) -> Bool {
        fileTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func startStopTapped(_ sender: Any) {
        if startStopButton.isSelected {
            startStopButton.isSelected = false
            stopRecording()
        }
        else {
            startStopButton.isSelected = true
            startRecording()
        }
    }
    
    func createFiles() {
        let input_file_name = fileTextField.text
        let base_name : String!
        
        if input_file_name != nil {
            base_name = input_file_name
        }
        else {
            base_name = "default"
        }
        
        let location_file = base_name+"_locations.txt"
        let heading_file = base_name+"_headings.txt"
        let rudder_file = base_name+"_rudder.txt"
        let command_file = base_name+"_commands.txt"
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            location_file_URL = dir.appendingPathComponent(location_file)
            heading_file_URL = dir.appendingPathComponent(heading_file)
            rudder_file_URL = dir.appendingPathComponent(rudder_file)
            command_file_URL = dir.appendingPathComponent(command_file)
        }
        
        let location_entries = "lat,lon,timestamp\n"
        let heading_entries = "heading,timestamp\n"
        let rudder_entries = "angle,timestamp\n"
        let command_entries = "command,timestamp\n"

        do {
            try location_entries.write(to: location_file_URL, atomically: false, encoding: .utf8)
        }
        catch {print("Could not create file")}
        
        do {
            try heading_entries.write(to: heading_file_URL, atomically: false, encoding: .utf8)
        }
        catch {print("Could not create file")}
        
        do {
            try rudder_entries.write(to: rudder_file_URL, atomically: false, encoding: .utf8)
        }
        catch {print("Could not create file")}
        
        do {
            try command_entries.write(to: command_file_URL, atomically: false, encoding: .utf8)
        }
        catch {print("Could not create file")}
    }
    
    func startRecording() {
        createFiles()
        LocationService.sharedInstance.startUpdating()
        button1.isEnabled = true
        button2.isEnabled = true
        button3.isEnabled = true
        button4.isEnabled = true
        button5.isEnabled = true
        rudderAngleSlider.isEnabled = true
    }
    
    func stopRecording() {
        LocationService.sharedInstance.stopUpdating()
        button1.isEnabled = false
        button2.isEnabled = false
        button3.isEnabled = false
        button4.isEnabled = false
        button5.isEnabled = false
        rudderAngleSlider.isEnabled = false
    }
    
    func tracingLocation(_ currentLocation: CLLocation) {
        let lat = String(format:"%.2f", currentLocation.coordinate.latitude)
        let lon = String(format:"%.2f", currentLocation.coordinate.longitude)
        let timestamp = time_formatter.string(from: currentLocation.timestamp)
        let entry = lat+","+lon+","+timestamp+"\n"
        //writing
        do {
            let fileHandle = try FileHandle(forWritingTo: location_file_URL)
            fileHandle.seekToEndOfFile()
            fileHandle.write(entry.data(using: .utf8)!)
            fileHandle.closeFile()
        } catch {
            print("Error writing to file \(error)")
        }
    }
    
    func tracingHeading(_ currentHeading: CLHeading) {
        let heading = String(format:"%.2f", currentHeading.trueHeading)
        let timestamp = time_formatter.string(from: currentHeading.timestamp)
        let entry = heading+","+timestamp+"\n"
        print(heading)
        //writing
        do {
            let fileHandle = try FileHandle(forWritingTo: heading_file_URL)
            fileHandle.seekToEndOfFile()
            fileHandle.write(entry.data(using: .utf8)!)
            fileHandle.closeFile()
        } catch {
            print("Error writing to file \(error)")
        }
    }
    
    func tracingLocationDidFailWithError(_ error: NSError) {
        //writing
        do {
            let fileHandle = try FileHandle(forWritingTo: location_file_URL)
            fileHandle.seekToEndOfFile()
            fileHandle.write("error".data(using: .utf8)!)
            fileHandle.closeFile()
        } catch {
            print("Error writing to file \(error)")
        }
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        rudder_angle = Double(rudderAngleSlider.value)
        print(rudder_angle)
        let timestamp = time_formatter.string(from: NSDate() as Date)
        let angle = String(format:"%.2f", rudderAngleSlider.value)
        let entry = angle+","+timestamp+"\n"
        //writing
        do {
            let fileHandle = try FileHandle(forWritingTo: rudder_file_URL)
            fileHandle.seekToEndOfFile()
            fileHandle.write(entry.data(using: .utf8)!)
            fileHandle.closeFile()
        } catch {
            print("Error writing to file \(error)")
        }
    }
}

