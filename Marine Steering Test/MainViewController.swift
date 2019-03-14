//
//  ViewController.swift
//  Marine Steering Test
//
//  Created by Lawrence Berry on 26/02/2019.
//  Copyright © 2019 Lawrence Berry. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

final class MainViewController: UIViewController, LocationServiceDelegate, UITextFieldDelegate, BluetoothSerialDelegate {
    func serialDidChangeState() {
        
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        
    }
    
    var range = 30
    var offset = 0
    
    var location_file_URL : URL!
    var heading_file_URL : URL!
    var rudder_file_URL : URL!
    var command_file_URL : URL!
    let time_formatter = DateFormatter()
    
    var rudder_angle = 0.0
    
    @IBOutlet weak var DisconnectButton: UIButton!
    @IBOutlet weak var ConnectButton: UIButton!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var fileTextField: UITextField!
    @IBOutlet weak var rangeField: UITextField!
    @IBOutlet weak var offsetField: UITextField!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var button10: UIButton!
    @IBOutlet weak var button11: UIButton!
    @IBOutlet weak var button12: UIButton!
    
    @IBOutlet weak var rudderAngleSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init serial
        serial = BluetoothSerial(delegate: self)
        // Make the ViewController a LocationService delegate
        LocationService.sharedInstance.delegate = self
        self.fileTextField.delegate = self
        time_formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        DisconnectButton.isEnabled = false
        self.fileTextField.delegate = self
        self.rangeField.delegate = self
        self.offsetField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func ConnectTapped(_ sender: Any) {
        ConnectButton.isEnabled = false
        serial.startScan()
        //Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(serial.stopScan), userInfo: nil, repeats: false)
        DisconnectButton.isEnabled = true
    }
    
    @IBAction func DisconnectTapped(_ sender: UIButton) {
        DisconnectButton.isEnabled = false
        ConnectButton.isEnabled = true
        serial.disconnect()
    }
    
    
    @IBAction func startStopTapped(_ sender: Any) {
        if startStopButton.isSelected {
            startStopButton.isSelected = false
            stopRecording()
            let value: UInt8 = 251
            let delta: UInt8 = 0
            let result: UInt8 = value &- delta
            serial.sendBytesToDevice([result])
        }
        else {
            startStopButton.isSelected = true
            startRecording()
            let value: UInt8 = 251
            let delta: UInt8 = 0
            let result: UInt8 = value &- delta
            serial.sendBytesToDevice([result])
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
        button6.isEnabled = true
        button7.isEnabled = true
        button8.isEnabled = true
        button9.isEnabled = true
        button10.isEnabled = true
        button11.isEnabled = true
        button12.isEnabled = true
        rudderAngleSlider.minimumValue = -Float(range)
        rudderAngleSlider.maximumValue = Float(range)
        rudderAngleSlider.isEnabled = true
    }
    
    func stopRecording() {
        LocationService.sharedInstance.stopUpdating()
        button1.isEnabled = false
        button2.isEnabled = false
        button3.isEnabled = false
        button4.isEnabled = false
        button5.isEnabled = false
        button6.isEnabled = false
        button7.isEnabled = false
        button8.isEnabled = false
        button9.isEnabled = false
        button10.isEnabled = false
        button11.isEnabled = false
        button12.isEnabled = false
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
        let new_rudder_angle_int = UInt8(Double(rudderAngleSlider.value)+90)
        let new_rudder_angle_int_w_offset = UInt8(Double(rudderAngleSlider.value)+90+Double(offset))
        if (new_rudder_angle_int != UInt8(rudder_angle)){
            rudder_angle = Double(new_rudder_angle_int)
            serial.sendBytesToDevice([new_rudder_angle_int_w_offset])
            print(new_rudder_angle_int)
        }
        
        //rudderAngleSlider.setValue(Float(rudder_angle_rounded), animated: true)

        
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
        print("Angle with offset: \(new_rudder_angle_int_w_offset)")
    }
    @IBAction func button1Tapped(_ sender: Any) {
        write_command_to_file(command: button1.currentTitle!)
    }
    
    @IBAction func button2Tapped(_ sender: Any) {
        write_command_to_file(command: button2.currentTitle!)
    }
    
    @IBAction func button3Tapped(_ sender: Any) {
        write_command_to_file(command: button3.currentTitle!)
    }
    
    @IBAction func button4Tapped(_ sender: Any) {
        write_command_to_file(command: button4.currentTitle!)
    }
    
    @IBAction func button5Tapped(_ sender: Any) {
        write_command_to_file(command: button5.currentTitle!)
    }
    
    @IBAction func button6Tapped(_ sender: Any) {
        write_command_to_file(command: button6.currentTitle!)
    }
    
    @IBAction func button7Tapped(_ sender: Any) {
        write_command_to_file(command: button7.currentTitle!)
    }
    
    @IBAction func button8Tapped(_ sender: Any) {
        write_command_to_file(command: button8.currentTitle!)
    }
    
    @IBAction func button9Tapped(_ sender: Any) {
        write_command_to_file(command: button9.currentTitle!)
    }
    
    @IBAction func button10Tapped(_ sender: Any) {
        write_command_to_file(command: button10.currentTitle!)
    }
    
    @IBAction func button11Tapped(_ sender: Any) {
        write_command_to_file(command: button11.currentTitle!)
    }
    
    @IBAction func button12Tapped(_ sender: Any) {
        write_command_to_file(command: button12.currentTitle!)
    }
    
    func write_command_to_file(command : String) {
        let timestamp = time_formatter.string(from: NSDate() as Date)
        let entry = command+","+timestamp+"\n"
        //writing
        do {
            let fileHandle = try FileHandle(forWritingTo: command_file_URL)
            fileHandle.seekToEndOfFile()
            fileHandle.write(entry.data(using: .utf8)!)
            fileHandle.closeFile()
        } catch {
            print("Error writing to file \(error)")
        }
    }

    @IBAction func rangeChanged(_ sender: Any) {
        if let new_range = Int(rangeField.text!) {
            range = new_range
        }
        print("Range: \(range)")
    }
    
    @IBAction func offsetChanged(_ sender: Any) {
        if let new_offset = Int(offsetField.text!) {
            offset = new_offset
        }
        print("Offset: \(offset)")
    }
    
}

