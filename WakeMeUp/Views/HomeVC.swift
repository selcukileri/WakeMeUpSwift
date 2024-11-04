//
//  ViewController.swift
//  WakeMeUp
//
//  Created by Selçuk İleri on 13.11.2023.
//

import UIKit
import SnapKit

class HomeVC: UIViewController {
    
    let placemarkText = HomeButtons()
    let settingsText = HomeButtons()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        title = "Wake Me Up"
        
    }
    
    private func configure(){
        view.backgroundColor = .systemBackground
        title = "Wake Me Up"
        
        placemarkText.setTitle("Placemarks", for: .normal)
        placemarkText.setImage(UIImage(systemName: "mappin"), for: .normal)
        placemarkText.addTarget(self, action: #selector(placemarkTapped), for: .touchUpInside)
        settingsText.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingsText.setTitle("Settings", for: .normal)
        settingsText.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        view.addSubview(placemarkText)
        view.addSubview(settingsText)
        
        placemarkText.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        settingsText.snp.makeConstraints { make in
            make.top.equalTo(placemarkText.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(placemarkText.snp.horizontalEdges)
            make.height.equalTo(100)
        }
    }
    
    @objc private func placemarkTapped(){
        let placemarksVC = PlacemarksVC()
        navigationController?.pushViewController(placemarksVC, animated: true)
    }
    
    @objc private func settingsTapped(){
        let settingsVC = SettingsVC()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
   
    
}

