//
//  Extension+UIButton.swift
//  SwiftyCompanion
//
//

import UIKit

extension UIButton.Configuration {
	
	public static func custom(with color: UIColor) -> UIButton.Configuration {
		var custom = UIButton.Configuration.filled()
		custom.buttonSize = .large
		custom.titlePadding = 7
		custom.baseBackgroundColor = color
		return custom
	}
	
}
