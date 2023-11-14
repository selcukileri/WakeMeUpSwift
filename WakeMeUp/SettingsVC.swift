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
    
    let distances = [500,750,1000]
    let alertOptions = ["Alarm", "Titreşim","Alarm ve Titreşim"]
    
    var selectedDistance: Int?
    var selectedAlertOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distancePicker.delegate = self
        distancePicker.dataSource = self
        alertPicker.delegate = self
        alertPicker.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        if let selectedDistance = selectedDistance, let selectedAlertOption = selectedAlertOption {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let newOptions = NSEntityDescription.insertNewObject(forEntityName: "Options", into: context)
            newOptions.setValue(selectedDistance, forKey: "distance")
            newOptions.setValue(selectedAlertOption, forKey: "alertOption")
            newOptions.setValue(UUID(), forKey: "id")
            do {
                try context.save()
                performSegue(withIdentifier: "toViewController", sender: nil)
            } catch {
                makeAlert(title: "Uyarı", message: error.localizedDescription)
            }
        } else {
            makeAlert(title: "Uyarı", message: "Lütfen metre/seçenek seçiniz.")
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
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == distancePicker {
            selectedDistance = distances[row]
        } else if pickerView == alertPicker {
            selectedAlertOption = alertOptions[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == distancePicker {
            return "\(distances[row]) metre"
        } else if pickerView == alertPicker {
            return alertOptions[row]
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
