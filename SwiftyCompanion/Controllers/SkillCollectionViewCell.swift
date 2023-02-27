//
//  SkillCollectionViewCell.swift
//  SwiftyCompanion
//
//

import UIKit

class SkillCollectionViewCell: UICollectionViewCell {
	
	
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var levelProgressView: UIProgressView!
	@IBOutlet var levelLabel: UILabel!
	@IBOutlet var paletteView: UIView!
	
	func configurate(name: String, level: Float) {
		nameLabel.text = name
		levelLabel.text = "\(level) lvl"
		levelProgressView.progress = level.truncatingRemainder(dividingBy: 1)
		paletteView.backgroundColor = .celadonBlue
		
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = CGRect(x: 0, y: 0, width: 215, height: 135)
		gradientLayer.colors = [UIColor.prussianBlue.cgColor, UIColor.prussianBlueSecond.cgColor]
		gradientLayer.shouldRasterize = true
		paletteView.layer.insertSublayer(gradientLayer, at: 0)
		
	}

}
