//
//  SettingsVC.swift
//  WakeMeUp
//
//  Created by Selçuk İleri on 13.11.2023.
//

import UIKit
import CoreData

class SettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var distancePicker: UIPickerView!
    @IBOutlet weak var alertPicker: UIPickerView!
    @IBOutlet weak var alertNamePicker: UIPickerView!
    
    let distances = [300,500,750,1000]
    let alertOptions = ["Alarm", "Titreşim","Alarm ve Titreşim"]
    let alertName = ["iPhone Alarm", "Pala Alarm", "iPhone Alarm2", "Perfect Alarm", "Alarm"]
    
    var selectedDistance: Int?
    var selectedAlertOption: String?
    var selectedAlertName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        distancePicker.delegate = self
        distancePicker.dataSource = self
        
        alertPicker.delegate = self
        alertPicker.dataSource = self
        
        alertNamePicker.delegate = self
        alertNamePicker.dataSource = self
        
        pickerView(distancePicker, didSelectRow: 0, inComponent: 0)
        pickerView(alertPicker, didSelectRow: 0, inComponent: 0)
        pickerView(alertNamePicker, didSelectRow: 0, inComponent: 0)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        if let selectedDistance = selectedDistance, let selectedAlertOption = selectedAlertOption, let selectedAlertName = selectedAlertName {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let newOptions = NSEntityDescription.insertNewObject(forEntityName: "Options", into: context)
            newOptions.setValue(selectedDistance, forKey: "distance")
            newOptions.setValue(selectedAlertOption, forKey: "alertOption")
            newOptions.setValue(selectedAlertName, forKey: "alertName")
            newOptions.setValue(UUID(), forKey: "id")
            do {
                try context.save()
                performSegue(withIdentifier: "toHomeViewController", sender: nil)
            } catch {
                makeAlert(title: "Uyarı", message: error.localizedDescription)
            }
        } else {
            makeAlert(title: "Uyarı", message: "Lütfen metre/seçenek/alarm seçiniz.")
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == distancePicker {
            return distances.count
        } else if pickerView == alertPicker {
            return alertOptions.count
        } else if pickerView == alertNamePicker {
            return alertName.count
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == distancePicker {
            selectedDistance = distances[row]
        } else if pickerView == alertPicker {
            selectedAlertOption = alertOptions[row]
        } else if pickerView == alertNamePicker {
            selectedAlertName = alertName[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == distancePicker {
            return "\(distances[row]) metre"
        } else if pickerView == alertPicker {
            return alertOptions[row]
        } else if pickerView == alertNamePicker {
            return alertName[row]
        }
        return nil
    }
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
}
