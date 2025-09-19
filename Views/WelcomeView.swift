//
//  ContentView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 22.05.2025..
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isLoggedIn: Bool
    @StateObject var viewModel = WelcomeViewModel()
    
    @StateObject var sharedRegisterViewModel = RegisterViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea(edges: .all)

                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 67/255, green: 35/255, blue: 105/255),
                        .black
                    ]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 500
                )
                .opacity(0.6)
                .ignoresSafeArea()

                VStack {
                    Text("ReelFeels")
                        .font(.custom("Poppins-Bold", size: 36))
                        .foregroundColor(.white)

                    Text("Podijeli svoje emocije i mišljenje nakon svakog odgledanog filma/serije.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    HStack(spacing: 20) {
                        ForEach(viewModel.emojis.indices, id: \.self) { index in
                            Text(viewModel.emojis[index])
                                .padding(.top)
                                .font(.system(size: 36))
                                .offset(y: viewModel.activeIndex == index ? -10 : 0)
                                .animation(.easeInOut(duration: 0.2), value: viewModel.activeIndex)
                        }
                    }

                    Spacer()

                    VStack {
                        NavigationLink(destination: LoginView(isLoggedIn: $isLoggedIn)) {
                            Text("Prijavi se")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(20)
                        }

                        NavigationLink(destination: RegisterView(viewModel: sharedRegisterViewModel)) {
                            Text("Registriraj se")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }

                        Button("Nastavi kao gost") {
                            // alert logika ovdje
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 32)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.activeIndex = (viewModel.activeIndex + 1) % viewModel.emojis.count
                            }
                        }
                    }

                    Spacer()
                }
            }
        }
    }
}

