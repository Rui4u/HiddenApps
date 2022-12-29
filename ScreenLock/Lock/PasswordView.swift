//
//  PasswordView.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/29.
//

import SwiftUI
struct PasswordManager {
    static let manager = PasswordManager()
    var password : String?
}

struct PasswordView: View {
    @Binding var showPassword : Bool
    @State var manager = PasswordManager.manager
    @State var password: String = ""
    @State var title = "输入密码"
    @FocusState private var usernameFieldIsFocused: Bool
    var body: some View {
        
        VStack {
            HStack(alignment: .top) {
                Button("关闭") {
                    showPassword = false
                }
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 100)
                    .foregroundColor(.white)
            }.padding()
            Text(title)
            ZStack {
                GeometryReader { reader in
                    
                    TextField("密码", text: $password)
                        .focused($usernameFieldIsFocused)
                        .frame(width: reader.size.width, height: 50)
                        .keyboardType(.phonePad)
                        .onChange(of: password) { newValue in
                            if (newValue.count > 6) {
                                password = String(newValue.dropFirst(0).prefix(6))
                            }
                            if (newValue.count == 6 && title == "输入密码") {
                                manager.password = newValue
                                title = "确认密码"
                                password = ""
                            } else if newValue.count == 6 && title == "确认密码" {
                                if (newValue == manager.password) {
                                    print("成功")
                                } else {
                                    print("失败")
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
        PasswordView(showPassword: .constant(true))
    }
}
