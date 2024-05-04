//
//  PlacemarksCell.swift
//  WakeMeUp
//
//  Created by Selçuk İleri on 3.05.2024.
//

import UIKit

class PlacemarksCell: UITableViewCell {
    
    let nameText = UILabel()
    let locationImage = UIButton()
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
        addSubview(locationImage)
        
        locationImage.setImage(UIImage(systemName: "mappin"), for: .normal)
        locationImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
        }
        
        nameText.textColor = .label
        nameText.adjustsFontSizeToFitWidth = true
        nameText.minimumScaleFactor = 0.9
        nameText.lineBreakMode = .byTruncatingTail
        backgroundColor = .systemBackground
        layer.cornerRadius = 5
        
        nameText.font = UIFont.systemFont(ofSize: 20)
        
        nameText.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(locationImage.snp.trailing).offset(8)
            make.height.equalTo(70)
        }

    }
}
