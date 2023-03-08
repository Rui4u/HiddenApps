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
    @State var showSelectorIcon = false
    let payManager = PaymentManager()
    var body: some View {
        LoadingView(isShowing: $showLoading)  {
            NavigationView {
                List {
                    Section("Application"){
                        Button("还原所有应用程序") {
                            ScreenLockManager.closeAll()
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
                    
                    Button("自定义图标") {
                        showSelectorIcon = true
                    }
                    
                    Section {
                        Button("捐赠") {
                            payManager.buy()
                        }
                    } header: {
                        Text("请开发者小哥哥喝杯奶茶~  😘")
                    } footer: {
    //                    Text("一次性升级，不限制隐藏App数量以及分组")
                    }
                }
                .navigationTitle("设置")
                .navigationBarTitleDisplayMode(.inline)
            }
            .onReceive(payManager.$showLoading) { showLoading = $0 }
            .onReceive(payManager.$showToast) { showToast = $0 }
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
            .sheet(isPresented: $showSelectorIcon, content: {
                AlertIconView(isShow: $showSelectorIcon)
                .presentationDetents([.height(180)])
                
            })
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



struct AlertIconView: View {
    @State var selected: String = ""
    @Binding var isShow: Bool
    var body: some View {
        ZStack {
            Color.init(white: 0.95)
                .ignoresSafeArea()
            VStack {
                HStack {
                    ChoseIconItem(selected: $selected, image: "undraw_Dog", title: "Dog", offset: 10,tapAction: tapAction)
                    ChoseIconItem(selected: $selected, image: "undraw_Cat", title: "Cat", offset: 10,tapAction: tapAction)
                }
                
                Button("确定") {
                    isShow = false
                    
                    IconManager.changeIcon(icon: selected)
                }
                .frame(width: 100, height: 40)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
            }
        }
    }
    
    func tapAction(title: String) {
        selected = title
    }
}

struct ChoseIconItem: View {
    @Binding var selected: String
    var image: String
    var title: String
    var offset : CGFloat
    var tapAction: (String)->()
    
    var body: some View {
        HStack {
            Image(systemName:selected == title ? "circle.inset.filled" : "circle")
                .padding()
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .background(Color.white)
                .cornerRadius(5)
        }
        .frame(width: 100, alignment: .center)
        .padding()
        .onTapGesture {
            tapAction(title)
        }
    }
}
