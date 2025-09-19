//
//  RegisterView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 28.05.2025..
//


import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: RegisterViewModel
    
    @Environment(\.dismiss) var dismiss
    @State private var showSuccessAlert = false

    var body: some View {
        ZStack {
            Color("PrimaryBackground").ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Text("Stvori svoj račun ✨")
                    .font(.custom("Poppins-Bold", size: 28))
                    .foregroundColor(.white)

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.caption)

                        TextField("example@domena.com", text: $viewModel.email)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lozinka")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.caption)

                        SecureField("••••••••", text: $viewModel.password)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Potvrdi lozinku")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.caption)

                        SecureField("••••••••", text: $viewModel.confirmPassword)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }

                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button("Registriraj se") {
                    viewModel.register { success in
                        if success {
                            showSuccessAlert = true
                        }
                    }
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(20)
                .padding(.horizontal)
                .alert(isPresented: $showSuccessAlert) {
                    Alert(
                        title: Text("Uspješna registracija 🎉"),
                        message: Text("Sada se možeš prijaviti sa svojim računom."),
                        dismissButton: .default(Text("OK"), action: {
                            dismiss()
                        })
                    )
                }
                Spacer()
            }
        }
    }
}
