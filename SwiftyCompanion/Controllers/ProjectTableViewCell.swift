//
//  ProjectTableViewCell.swift
//  SwiftyCompanion
//
//

import UIKit

class ProjectTableViewCell: UITableViewCell {

	@IBOutlet var statusLabel: UILabel!
	@IBOutlet var statusLogo: UIImageView!
	@IBOutlet var nameLabel: UILabel!
	
	@IBOutlet var markLabel: UILabel!
	@IBOutlet var paletteView: UIView!
	func configurate(from project: ProjectsUser) {
		
		nameLabel.text = project.project?.name ?? "none"
		statusLabel.text = project.status ?? "none"
		let mark = project.finalMark ?? -1
		markLabel.text = (mark == -1) ? "" : "\(mark)"
		paletteView.backgroundColor = .systemGray6
		
		if project.validated != nil && project.validated == true {
						paletteView.layer.cornerRadius = 10
			statusLogo.image = UIImage(systemName: "checkmark.seal")
			statusLogo.tintColor = .systemGreen
		} else if project.finalMark != nil {
			paletteView.layer.cornerRadius = 10
			statusLogo.image = UIImage(systemName: "xmark.seal")
			statusLogo.tintColor = .imperialRed
		} else {
			
			paletteView.layer.cornerRadius = 10
			statusLogo.image = UIImage(systemName: "clock")
			statusLogo.tintColor = .gray
		}
		
	}
	
}
