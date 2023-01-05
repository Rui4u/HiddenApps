//
//  PasswordView.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/29.
//

import SwiftUI

struct PasswordView: View {
    @Binding var showPassword : Bool
    @State var manager : PasswordManager
    @State var password: String = ""
    @FocusState private var usernameFieldIsFocused: Bool
    @State var attempts: Int = 0
    var body: some View {
        
        VStack {
            HStack(alignment: .top) {
                if manager.type != .inputPassword {
                    Button("关闭") {
                        showPassword = false
                    }
                }
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 100)
                    .foregroundColor(.white)
            }.padding()
            ZStack {
                let error = manager.setPassword.status == .error || manager.setPassword.status == .inputError
                Text(manager.setPassword.status.title())
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5))
                    .foregroundColor(error ? .white: .black)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(error ? .red : .white  , lineWidth: 2)
                            .background(error ? .red : .white)
                            .cornerRadius(10)
                    )
                    .modifier(Shake(animatableData: CGFloat(attempts)))
            }
            
            ZStack {
                GeometryReader { reader in
                    
                    TextField("密码", text: $password)
                        .focused($usernameFieldIsFocused)
                        .frame(width: reader.size.width, height: 50)
                        .keyboardType(.phonePad)
                        .onChange(of: password) { newValue in
                            if (newValue.count > 6) {
                                password = String(newValue.dropFirst(0).prefix(6))
                                return
                            }
                            
                            if manager.type == .substitutePassword || manager.type == .password {
                                if (newValue.count == 6 && manager.setPassword.status == .first) {
                                    manager.setPassword.password1 = newValue
                                    manager.setPassword.status = .second
                                    password = ""
                                } else if newValue.count == 6 && manager.setPassword.status == .second {
                                    manager.setPassword.password2 = newValue
                                    if (manager.setPassword.compair()) {
                                        if manager.type == .password {
                                            PasswordManager.savePassword(newValue)
                                        } else if manager.type == .substitutePassword {
                                            PasswordManager.saveSubstitutePassword(newValue)
                                        }
                                        
                                        showPassword = false
                                    } else {
                                        withAnimation {
                                            attempts += 1
                                        }
                                        manager.setPassword.status = .error
                                        password = ""
                                    }
                                } else if password.count > 0 && manager.setPassword.status == .error {
                                    manager.setPassword.status = .second
                                }
                            } else if manager.type == .inputPassword {
                                if (newValue.count == 6) {
                                    if newValue == manager.locationPassword {
                                        showPassword = false
                                        password = ""
                                    } else if newValue == manager.locationSubstitutePassword {
                                        showPassword = false
                                        LaunchManager.shared.type = .note
                                        password = ""
                                    } else {
                                        withAnimation {
                                            attempts += 1
                                        }
                                        manager.setPassword.status = .inputError
                                        password = ""
                                    }
                                } else if password.count > 0 && manager.setPassword.status == .inputError  {
                                    manager.setPassword.status = .first
                                }
                                
                            }
                        }
                    HStack(spacing:20) {
                        ForEach(0..<6) { index in
                            Image(systemName:index < password.count ? "circle.fill" : "circle")
                        }
                    }
                    .onTapGesture {
                        usernameFieldIsFocused = true
                    }
                    .frame(width: reader.size.width, height: 50)
                    .background(Color.white)
                }
            }
        }
        .onAppear {
            usernameFieldIsFocused = true
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(showPassword: .constant(true), manager: PasswordManager(type: .inputPassword))
    }
}
