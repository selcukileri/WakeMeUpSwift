//
//  PlacemarksCell.swift
//  WakeMeUp
//
//  Created by Selçuk İleri on 3.05.2024.
//

import UIKit

class PlacemarksCell: UITableViewCell {
    
    let nameText = UILabel()
    static let reuseID = "PlacemarksCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        addSubview(nameText)
        backgroundColor = .black
        layer.cornerRadius = 50
        accessoryType = .disclosureIndicator
        nameText.font = UIFont.systemFont(ofSize: 20)
        nameText.backgroundColor = .black
        nameText.layer.cornerRadius = 60
        nameText.textColor = .white
        
        
        nameText.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.width.equalToSuperview().inset(15)
            make.height.equalTo(70)
        }
    }
}
