//
//  ViewController.swift
//  WakeMeUp
//
//  Created by Selçuk İleri on 13.11.2023.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var placemarkText: UILabel!
    @IBOutlet weak var settingsText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wake Me Up"
        
        let placemarkGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(placemarkTapped))
        placemarkText.isUserInteractionEnabled = true
        placemarkText.addGestureRecognizer(placemarkGestureRecognizer)
        
        let settingsGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(settingsTapped))
        settingsText.isUserInteractionEnabled = true
        settingsText.addGestureRecognizer(settingsGestureRecognizer)
        
    }
    
    @objc func placemarkTapped(){
        performSegue(withIdentifier: "toPlacemarksVC", sender: nil)
    }
    
    @objc func settingsTapped(){
        performSegue(withIdentifier: "toSettingsVC", sender: nil)
    }
    
   
    
}

