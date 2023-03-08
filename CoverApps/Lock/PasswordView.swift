//
//  PasswordView.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/29.
//

import SwiftUI



struct PasswordView: View {
    @ObservedObject var manager : PasswordManager
    @State var password: String = ""
    @FocusState private var usernameFieldIsFocused: Bool
    
    var body: some View {
        VStack {
            PasswordViewCloseButton(viewShow: $manager.isPresent, showClose: manager.type != .inputPassword)
            
            let error = manager.setPassword.status == .error || manager.setPassword.status == .inputError
            PasswordOrderView(title: manager.setPassword.status.title(), error: error, attempts: $manager.attempts)
            
            PasswordViewInputView(manager: manager)
        }
    }
}

fileprivate struct PasswordOrderView: View {
    var title: String
    var error: Bool
    
    @Binding var attempts: Int
    var body: some View {
        Text(title)
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
}

fileprivate struct PasswordViewCloseButton: View {
    @Binding var viewShow: Bool
    var showClose: Bool
    var body: some View {
        HStack(alignment: .top) {
            if showClose {
                Button("关闭") {
                    viewShow = false
                }
            }
            RoundedRectangle(cornerRadius: 0)
                .frame(height: 100)
                .foregroundColor(.white)
        }.padding()
    }
}

fileprivate struct PasswordViewInputView: View {
    
    @ObservedObject var manager : PasswordManager
    @FocusState private var usernameFieldIsFocused: Bool
    
    var body: some View {
        ZStack {
            GeometryReader { reader in
                
                TextField("密码", text: $manager.password)
                    .focused($usernameFieldIsFocused)
                    .frame(width: reader.size.width, height: 50)
                    .keyboardType(.phonePad)
                    .onChange(of: manager.password, perform: manager.passwordInputStatus)
                    .onChange(of: manager.attempts) { newValue in
                        withAnimation { manager.attempts += 1 }
                    }
                HStack(spacing:20) {
                    ForEach(0..<6) { index in
                        Image(systemName:index < manager.password.count ? "circle.fill" : "circle")
                    }
                }
                .onTapGesture {
                    usernameFieldIsFocused = true
                }
                .frame(width: reader.size.width, height: 50)
                .background(Color.white)
            }
        }
        .onAppear {
            usernameFieldIsFocused = true
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(manager: PasswordManager(type: .inputPassword) )
    }
}
