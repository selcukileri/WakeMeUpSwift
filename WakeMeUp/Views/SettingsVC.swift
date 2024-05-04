//
//  SettingsVC.swift
//  WakeMeUp
//
//  Created by Selçuk İleri on 13.11.2023.
//

import UIKit
import CoreData
import SnapKit

class SettingsVC: UIViewController {

    let distanceLabel = UILabel()
    let distanceButton = UIButton()
    let alertLabel = UILabel()
    let alertButton = UIButton()
    let alertNameLabel = UILabel()
    let alertNameButton = UIButton()
    let saveButton = UIButton()
    
    
    let distances = [300,500,750,1000]
    let alertOptions = ["Alarm", "Titreşim","Alarm ve Titreşim"]
    let alertName = ["iPhone Alarm", "Pala Alarm", "iPhone Alarm2", "Perfect Alarm", "Alarm"]
    
    var choosenDistance: String?
    var choosenAlertOption: String?
    var choosenAlertName: String?
    var menuItems: [UIMenuElement] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenu()
        configure()

    }
    
    func setupMenu() {
        let distanceClosure = {(action: UIAction) in
            self.distanceButton.setTitle(action.title, for: .normal)
            self.choosenDistance = action.title
        }
        
        let alertClosure = {(action: UIAction) in
            self.alertButton.setTitle(action.title, for: .normal)
            self.choosenAlertOption = action.title
        }
        
        let alertNameClosure = {(action: UIAction) in
            self.alertNameButton.setTitle(action.title, for: .normal)
            self.choosenAlertName = action.title
        }
        
        var distanceMenuItems: [UIMenuElement] = []
        var alertMenuItems: [UIMenuElement] = []
        var alertNameMenuItems: [UIMenuElement] = []
        
        for distance in distances {
            distanceMenuItems.append(UIAction(title: String(distance), handler: distanceClosure))
        }
        
        for option in alertOptions {
            alertMenuItems.append(UIAction(title: option, handler: alertClosure))
        }
        
        for name in alertName {
            alertNameMenuItems.append(UIAction(title: name, handler: alertNameClosure))
        }
        
        let distanceMenu = UIMenu(options: .displayInline, children: distanceMenuItems)
        let alertMenu = UIMenu(options: .displayInline, children: alertMenuItems)
        let alertNameMenu = UIMenu(options: .displayInline, children: alertNameMenuItems)
        
        distanceButton.menu = distanceMenu
        alertButton.menu = alertMenu
        alertNameButton.menu = alertNameMenu
        distanceButton.showsMenuAsPrimaryAction = true
        alertButton.showsMenuAsPrimaryAction = true
        alertNameButton.showsMenuAsPrimaryAction = true
    }

    
    private func configure(){
        view.backgroundColor = .systemBackground
        view.addSubview(distanceLabel)
        view.addSubview(distanceButton)
        view.addSubview(alertLabel)
        view.addSubview(alertButton)
        view.addSubview(alertNameLabel)
        view.addSubview(alertNameButton)
        view.addSubview(saveButton)
        
        
        distanceLabel.text = "Mesafe Seçiniz"
        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.leading.equalTo(32)
            make.height.equalTo(40)
        }
        
        distanceButton.setTitle("Mesafeler", for: .normal)
        distanceButton.setTitleColor(.systemBlue, for: .normal)
//        distanceButton.addTarget(self, action: #selector(distanceButtonTapped), for: .touchUpInside)
        distanceButton.snp.makeConstraints { make in
            make.centerY.equalTo(distanceLabel.snp.centerY)
            make.trailing.equalTo(-32)
            make.height.equalTo(40)
        }
        
        alertLabel.text = "Alarm Tipi Seçiniz"
        alertLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel.snp.bottom).offset(64)
            make.leading.equalTo(distanceLabel.snp.leading)
            make.height.equalTo(40)
        }
        
        alertButton.setTitle("Alarmlar", for: .normal)
        alertButton.setTitleColor(.systemBlue, for: .normal)
//        alertButton.addTarget(self, action: #selector(alertButtonTapped), for: .touchUpInside)
        alertButton.snp.makeConstraints { make in
            make.centerY.equalTo(alertLabel.snp.centerY)
            make.trailing.equalTo(distanceButton.snp.trailing)
            make.height.equalTo(40)
        }
        
        alertNameLabel.text = "Alarm Ismi Seçiniz"
        alertNameLabel.snp.makeConstraints { make in
            make.top.equalTo(alertLabel.snp.bottom).offset(64)
            make.leading.equalTo(alertLabel.snp.leading)
            make.height.equalTo(40)
        }
        
        alertNameButton.setTitle("Alarm Isimleri", for: .normal)
        alertNameButton.setTitleColor(.systemBlue, for: .normal)
//        alertNameButton.addTarget(self, action: #selector(alertNameButtonTapped), for: .touchUpInside)
        alertNameButton.snp.makeConstraints { make in
            make.centerY.equalTo(alertNameLabel.snp.centerY)
            make.trailing.equalTo(alertButton.snp.trailing)
            make.height.equalTo(40)
        }
        
        saveButton.setTitle("Kaydet", for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonClicked), for: .touchUpInside)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(alertNameLabel.snp.bottom).offset(64)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
    }

    @objc func saveButtonClicked() {

        guard let selectedDistance = choosenDistance else {
            makeAlert(title: "Uyarı", message: "Lütfen mesafe seçiniz.")
            return
        }
        guard let selectedAlertOption = choosenAlertOption else {
            makeAlert(title: "Uyarı", message: "Lütfen alarm tipi seçiniz.")
            return
        }
        guard let selectedAlertName = choosenAlertName else {
            makeAlert(title: "Uyarı", message: "Lütfen alarm ismi seçiniz.")
            return
        }
        
        let selectedDistanceInt = Int(selectedDistance)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newOptions = NSEntityDescription.insertNewObject(forEntityName: "Options", into: context)
        newOptions.setValue(selectedDistanceInt, forKey: "distance")
        newOptions.setValue(selectedAlertOption, forKey: "alertOption")
        newOptions.setValue(selectedAlertName, forKey: "alertName")
        print("selected alert Name: \(selectedAlertName)")
        newOptions.setValue(UUID(), forKey: "id")
        do {
            try context.save()
            let homeVC = HomeVC()
            navigationController?.pushViewController(homeVC, animated: true)
        } catch {
            makeAlert(title: "Uyarı", message: error.localizedDescription)
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
}
