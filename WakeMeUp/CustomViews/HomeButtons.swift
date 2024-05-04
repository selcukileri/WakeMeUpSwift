//
//  WMButton.swift
//  WakeMeUp
//
//  Created by Selçuk İleri on 3.05.2024.
//

import UIKit

class HomeButtons: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        setTitleColor(.label, for: .normal)
        backgroundColor = .systemBackground
        titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        contentHorizontalAlignment = .leading
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        layer.cornerRadius = 15
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped(){
        
    }

}
