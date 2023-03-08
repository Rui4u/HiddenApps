//
//  SettingPage.swift
//  CoverApps
//
//  Created by sharui on 2023/1/18.
//

import SwiftUI


struct SettingPage: View {

    @State var passwordManager = PasswordManager(type: .password)
    @State var substitutePasswordManager =  PasswordManager(type: .substitutePassword)
        
    @State var passwordViewPresent = false
    @State var substitutePasswordViewPresent = false
    @State var showPasswordToggle = false;
    @State var showSubstitutePasswordToggle = false;
    @State var showToast = false
    @State var showLoading = false
    let payManager = PaymentManager()
    var body: some View {
        LoadingView(isShowing: $showLoading)  {
            NavigationView {
                List {
                    Section("Application"){
                        Button("还原所有应用程序") {
                            ScreenLockManager.closeAllGroup()
                        }
                    }
                    
                    Section {
                        HStack {
                            Toggle(isOn: $showPasswordToggle) {
                                Text("设置密码")
                            }.onChange(of: showPasswordToggle) { newValue in
                                if newValue {
                                    passwordManager.isPresent = true
                                } else {
                                    PasswordManager.savePassword("")
                                    updatePasswordSwitch()
                                }
                            }
                        }
                        
                        HStack {
                            Toggle(isOn: $showSubstitutePasswordToggle) {
                                Text("设置替身密码")
                            }
                            .onChange(of: showSubstitutePasswordToggle) { newValue in
                                if newValue {
                                    substitutePasswordManager.isPresent = true
                                } else {
                                    PasswordManager.saveSubstitutePassword("")
                                    updatePasswordSwitch()
                                }
                            }
                        }.disabled(!showPasswordToggle)
                        
                        
                        
                        
                    } header: {
                        Text("安全")
                    } footer: {
                        Text("设置替身密码后，App会伪装成记事本App")
                    }
                    
                    
                    Section {
                        Button("捐赠") {
                            payManager.buy()
                        }
    //                    Button("自定义图标") {
    //                        IconManager.changeIcon()
    //                    }
                    } header: {
                        Text("感谢一下开发者小哥哥吧~  😘")
                    } footer: {
    //                    Text("一次性升级，不限制隐藏App数量以及分组")
                    }
                }
                .navigationTitle("设置")
                .navigationBarTitleDisplayMode(.inline)
            }
            .onReceive(payManager.$showToast) { showLoading = $0 }
            .onReceive(passwordManager.$isPresent) {
                passwordManager.reset()
                passwordViewPresent = $0
            }
            .onReceive(substitutePasswordManager.$isPresent) {
                substitutePasswordManager.reset()
                substitutePasswordViewPresent = $0  
            }
            .toast(isShow: $showToast, info:payManager.message, duration: 1)
            .onAppear {
                updatePasswordSwitch()
            }
            .sheet(isPresented: $passwordViewPresent , onDismiss: {
                updatePasswordSwitch()
            }) {
                PasswordView(manager: passwordManager)
            }
            .sheet(isPresented: $substitutePasswordViewPresent, onDismiss: {
                updatePasswordSwitch()
            }) {
                PasswordView(manager: substitutePasswordManager)
            }
        }
    }
    
    func updatePasswordSwitch() {
        let open = PasswordManager.updatePasswordSwitch()
        showPasswordToggle = open.a
        showSubstitutePasswordToggle = open.b
    }
}



struct SettingPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingPage()
    }
}

