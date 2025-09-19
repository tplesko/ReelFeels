//
//  LoginViewModel.swift
//  ReelFeels
//
//  Created by Tea Pleško on 28.05.2025..
//


import Foundation
import FirebaseAuth
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    func login(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil

        AuthService.shared.login(email: email, password: password) {
            result in DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}
