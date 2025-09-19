//
//  RegisterViewModel.swift
//  ReelFeels
//
//  Created by Tea Pleško on 28.05.2025..
//

import SwiftUI
import Combine
import Firebase
import FirebaseFirestore

class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?

    func register(completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Sva polja su obavezna."
            completion(false)
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Lozinke se ne podudaraju."
            completion(false)
            return
        }

        AuthService.shared.register(email: email, password: password){
            result in DispatchQueue.main.async {
                switch result {
                    case .success(let authResult):
                        let user = authResult.user
                        let randomUsername = "user" + UUID().uuidString.prefix(6)
                        
                        let newUser = User(id: user.uid, email: user.email ?? "", username: randomUsername)
                        
                        let db = Firestore.firestore()
                        do{
                            try db.collection("users").document(user.uid).setData(from: newUser)
                            completion(true)
                        }
                        catch{
                            self.errorMessage = "Neuspješno spremanje korisnika: \(error.localizedDescription)"
                            completion(false)
                        }

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}
