//
//  SearchViewController.swift
//  SwiftyCompanion
//
//

import UIKit
import AuthenticationServices

class SearchViewController: UIViewController {

	@IBOutlet weak var searchTF: UITextField!
	@IBOutlet weak var searchButton: UIButton!
	
	var bearer_token: String?
		
	override func viewDidLoad() {
        super.viewDidLoad()
		oauth()
		searchTF.delegate = self
		configurateButton()
		addImageToTextField()
		
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = view.bounds
		gradientLayer.colors = [UIColor.prussianBlue.cgColor, UIColor.prussianBlueSecond.cgColor]
		gradientLayer.shouldRasterize = true
		view.layer.insertSublayer(gradientLayer, at: 0)
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		searchTF.text = nil
	}
	
	
	@IBAction func searchButtonAction() {
		getUser()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let detailView = segue.destination as? DetailViewController else { return }
		guard let user = sender as? User else { return }
		detailView.user = user
		
		guard let cursuses = user.cursusUsers else { return }
		cursuses.forEach { cursus in
			if cursus.grade == "Member" || cursus.grade == "Learner" {
				detailView.cursus = cursus
				return
			}
		}
	}

}


// MARK: - Private Methods

extension SearchViewController {
	
	private func showAlert(with title: String, and message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default) { _Arg in
			self.searchTF.text = nil
		}
		alert.addAction(okAction)
		present(alert, animated: true, completion: nil)
	}
	
	private func configurateButton() {
		searchButton.configuration = .custom(with: .honewDew)
		searchButton.setTitle("Search", for: .normal)
		searchButton.setTitleColor(.prussianBlue, for: .normal)
	}
	
	private func addImageToTextField() {
		let image = UIImage(systemName: "magnifyingglass")
		guard let img = image else { return }
		
		let paddingView = UIView(frame: CGRect(
			x: 0, y: 0,
			width: 30, height: Int(searchTF.frame.size.height)
		))
		
		let leftImage = UIImageView(frame: CGRect(
			x: 0, y: 0,
			width: 20, height: 20
		))
		
		leftImage.contentMode = .scaleAspectFit
		leftImage.center = paddingView.center
		leftImage.image = img
		leftImage.tintColor = .systemGray3
		paddingView.addSubview(leftImage)
		
		searchTF.leftView = paddingView
		searchTF.leftViewMode = .always
	}
	
	private func oauth() {
		NetworkManager.shared.postRequestToken(for: self) { result in
			switch result {
                
				case .success(let code):
					self.getToken(with: code)
				case .failure(let error):
					print(error.localizedDescription)
					print("error")
			}
		}
	}
	
	private func getToken(with code: String) {
		NetworkManager.shared.fetchAccessToken(for: code) { result in
			switch result {
				case .success(let token):
					self.bearer_token = token.accessToken
				case .failure(let error):
					print(error.localizedDescription)
					self.showAlert(with: "Error", and: "Can't get token")
			}
		}
	}
	
	private func getUser() {
		guard let bearer = self.bearer_token else {
			showAlert(with: "Error", and: "No Token")
			return
		}
		guard let login = searchTF.text, login.count > 0 else { return }
		let path = "/v2/users/" + login.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
		NetworkManager.shared.fetch(dataType: User.self, bearer: bearer, path: path) { result in
			switch result {
				case .success(let user):
					guard user.id != nil else {
                        DispatchQueue.main.async {
                            let text = self.searchTF.text == nil ? "" : self.searchTF.text
                            self.showAlert(with: "Error", and: "Can't find this user: \(text!)")}
						return
					}
					self.performSegue(withIdentifier: "detailView", sender: user)
				case .failure(let error):
					print(error.localizedDescription)
					DispatchQueue.main.async {
						let text = self.searchTF.text == nil ? "" : self.searchTF.text
						self.showAlert(with: "Error", and: "Can't find this user: \(text!)")
					}
			}
		}
	}
}


// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		view.endEditing(true)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == searchTF {
			getUser()
			textField.resignFirstResponder()
		}
		return true
	}
	
}


// MARK: - ASWebAuthenticationPresentationContextProviding

extension SearchViewController: ASWebAuthenticationPresentationContextProviding {
	func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		ASPresentationAnchor()
	}
}
