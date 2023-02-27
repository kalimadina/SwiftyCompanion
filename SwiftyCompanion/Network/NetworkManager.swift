//
//  NetworkManager.swift
//  SwiftyCompanion
//
//

import UIKit
import AuthenticationServices

enum NetworkError: Error {
	case invalidURL, noData, noToken, decodingError
}

class NetworkManager {
	
	static let shared = NetworkManager()
	private init() {}
	
	private let UID = "u-s4t2ud-4981dc0cf4abf7c05189a13f4d1b40f4b0097b1755e9f2f325bc6a01b2d3d141"
	private let SECRET = "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"
	
	private let scheme = "https"
	private let host = "api.intra.42.fr"
	private let path = "/oauth/token"
	private let redirectURLHostAllowed = "companion://companion".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
	
	
	func postRequestToken(for delegate: UIViewController, complition: @escaping (Result<String, NetworkError>) -> Void) {
		
		var components  = URLComponents()
		components.scheme = "https"
		components.host = "api.intra.42.fr"
		components.path = "/oauth/authorize"
		components.queryItems = [
				URLQueryItem(name: "client_id", value: UID),
				URLQueryItem(name: "redirect_uri", value: "companion://companion"),
				URLQueryItem(name: "response_type", value: "code"),
				URLQueryItem(name: "scope", value: "public"),
				URLQueryItem(name: "state", value: "4815162342")
			]
		guard let url = components.url else {
			complition(.failure(.invalidURL))
			return
		}

		let webAuthSession = ASWebAuthenticationSession(url: url, callbackURLScheme: redirectURLHostAllowed) { data, error in
			guard let replyData = data else {
                DispatchQueue.main.async {
                    complition(.failure(.noData))}
				return
			}
			guard let codeItem = replyData.query else {
                DispatchQueue.main.async {
                    complition(.failure(.decodingError))}
				return
			}
			DispatchQueue.main.async {
				complition(.success(codeItem))
			}
			
		}
		webAuthSession.presentationContextProvider = (delegate as! ASWebAuthenticationPresentationContextProviding)
		webAuthSession.start()
	}
	
	
	func fetchAccessToken(for code: String, complition: @escaping (Result<TokenData, NetworkError>) -> Void) {

		var codeForToken = code.replacingOccurrences(of: "code=", with: "")
		codeForToken = codeForToken.replacingOccurrences(of: "&state=4815162342", with: "")
		print("Code: \(codeForToken)")
		var components  = URLComponents()
		components.scheme = "https"
		components.host = "api.intra.42.fr"
		components.path = "/oauth/token"
		components.queryItems = [
			URLQueryItem(name: "grant_type", value: "client_credentials"),
			URLQueryItem(name: "client_id", value: self.UID),
			URLQueryItem(name: "client_secret", value: self.SECRET)
//			URLQueryItem(name: "code", value: codeForToken),
//			URLQueryItem(name: "redirect_uri", value: "companion://companion"),
//			URLQueryItem(name: "state", value: "4815162342")
		]
		guard let url = components.url else {
			complition(.failure(.invalidURL))
			return
		}
        print(url)
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		URLSession.shared.dataTask(with: request) { (data, _, error) in
			guard let data = data else {
                DispatchQueue.main.async {
                    complition(.failure(.noData))}
				return
			}
			
			do {
				let tokenData = try JSONDecoder().decode(TokenData.self, from: data)
                DispatchQueue.main.async {
                    complition(.success(tokenData))}
			} catch {
                DispatchQueue.main.async {
                    complition(.failure(.noData))}
			}
			
		}.resume()
	}
	
	
	func fetch<T: Decodable>(dataType: T.Type, bearer: String, path: String, complition: @escaping(Result<T, NetworkError>) -> Void) {
		
		var components  = URLComponents()
		components.scheme = "https"
		components.host = "api.intra.42.fr"
		components.path = path
		
		guard let url = components.url else {
			complition(.failure(.invalidURL))
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("Bearer " + bearer, forHTTPHeaderField: "Authorization")
		
		URLSession.shared.dataTask(with: request) { data, _, error in
			guard let data = data else {
				complition(.failure(.noData))
				return
			}
			do {
				let type = try JSONDecoder().decode(T.self, from: data)
				DispatchQueue.main.async {
					complition(.success(type))
				}
			} catch {
				complition(.failure(.noData))
			}
		}.resume()
	}
	
	func fetchImage(from url: String?, completion: @escaping(Result<Data, NetworkError>) -> Void) {
		guard let url = URL(string: url ?? "") else {
			completion(.failure(.invalidURL))
			return
		}
		DispatchQueue.global().async {
			guard let imageData = try? Data(contentsOf: url) else {
				completion(.failure(.noData))
				return
			}
			DispatchQueue.main.async {
				completion(.success(imageData))
			}
		}
	}
	
}
