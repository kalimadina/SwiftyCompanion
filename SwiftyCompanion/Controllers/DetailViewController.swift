//
//  DetailViewController.swift
//  SwiftyCompanion
//
//

import UIKit

class DetailViewController: UIViewController {
		
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var avatarImageView: UIImageView!
	@IBOutlet var emailLabel: UILabel!
	@IBOutlet var walletLabel: UILabel!
	@IBOutlet var campusLabel: UILabel!
	@IBOutlet var poolLabel: UILabel!
	@IBOutlet var paletteView: UIView!
	@IBOutlet var levelProgressView: UIProgressView!
	@IBOutlet var levelLabel: UILabel!
	
	@IBOutlet var projectsTableView: UITableView!
	@IBOutlet var skillsCollectionView: UICollectionView!
	
	var user: User?
	var cursus: CursusUser?
	
	@IBOutlet var heightConstant: NSLayoutConstraint!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		configurateProfile()
		configurateImage()
		configurateProgressView()
		
		skillsCollectionView.delegate = self
		skillsCollectionView.dataSource = self
		projectsTableView.delegate = self
		projectsTableView.dataSource = self
		
		heightConstant.constant = CGFloat((user?.projectsUsers?.count ?? 3) * 102)
		projectsTableView.allowsSelection = false
		projectsTableView.rowHeight = UITableView.automaticDimension
		projectsTableView.separatorStyle = .none
    }
	
	override func viewDidLayoutSubviews() {
		configurateAvatar()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		configurateGradient()
	}
    

}


// MARK: - UICollectionViewDelegate

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		cursus?.skills?.count ?? 2
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = skillsCollectionView.dequeueReusableCell(withReuseIdentifier: "skillCell", for: indexPath) as! SkillCollectionViewCell
		guard let cursus = cursus else { return cell }
		cell.configurate(name: cursus.skills?[indexPath.row].name ?? "none", level: Float(cursus.skills?[indexPath.row].level ?? 0))
		return cell
	}
}


// MARK: - UITableViewContoller

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		user?.projectsUsers?.count ?? 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = projectsTableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectTableViewCell
		guard let project = user?.projectsUsers?[indexPath.row] else { return cell }
		cell.configurate(from: project)
		return cell
	}
	
	
}



// MARK: - Class Private Methods

extension DetailViewController {
	
	private func configurateProgressView() {
		guard let curcuses = user?.cursusUsers else { return }
		curcuses.forEach { curcus in
			if curcus.grade == "Member" {
				guard let level = curcus.level else { return }
				levelProgressView.progress = Float(level.truncatingRemainder(dividingBy: 1))
				return
			}
		}
	}
	
	private func configurateImage() {

		let imageUrl = (user?.imageURL == nil)
			? "https://cdn.intra.42.fr/users/default.png"
			: user?.imageURL
		
		guard let url = URL(string: imageUrl!) else { return }
		DispatchQueue.global().async {
			if let data = try? Data(contentsOf: url) {
				DispatchQueue.main.async {
					self.avatarImageView.image = UIImage(data: data)
					self.avatarImageView.contentMode = .scaleAspectFill
				}
			}
		}
	}
	
	private func configurateProfile() {
		nameLabel.text = user?.usualFullName ?? "none"
		poolLabel.text = "\(user?.poolMonth?.capitalized ?? "none") \(user?.poolYear ?? "")"
		campusLabel.text = user?.campus?[0].name ?? "none"
		walletLabel.text = "\(user?.wallet ?? 0)"
		emailLabel.text = user?.email ?? "none"
		levelLabel.text = "\(user?.cursusUsers?[1].level ?? 0) lvl"
	}
	
	private func configurateAvatar() {
		avatarImageView.layer.borderWidth = 3
		avatarImageView.layer.masksToBounds = true
		avatarImageView.layer.borderColor = UIColor.white.cgColor
		avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
		avatarImageView.backgroundColor = .systemGray6
	}
	
	private func configurateGradient() {
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = paletteView.bounds
		gradientLayer.colors = [UIColor.prussianBlue.cgColor, UIColor.prussianBlueSecond.cgColor]
		gradientLayer.shouldRasterize = true
		paletteView.layer.insertSublayer(gradientLayer, at: 0)
	}
}
