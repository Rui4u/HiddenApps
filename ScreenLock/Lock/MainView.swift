//
//  MainView.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/27.
//

import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity
import Foundation

struct MainView: View {
    @State private var selection: Tab = .featured
    
    enum Tab {
        case featured
        case setting
    }
    
    init() {
        UITabBar.appearance().backgroundColor = .white //设置背景色，否则背景色为透明颜色
    }
    
    var body: some View {
        TabView(selection: $selection) {
            CategoryHome()
                .tabItem{//使用label 创建tabitem图文
                    Label("应用程序", systemImage: "apps.iphone.badge.plus")
                }
                .tag(Tab.featured)
            
            YLMine()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(Tab.setting)
        }
        .accentColor(.blue) //设置文字默认选中颜色
    }
}
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct CategoryHome: View {
    @ObservedObject var manager: ScreenLockManager = ScreenLockManager.manager
    @State var presentEdit: Bool = false
    @State var groupName: String = ""
    @State var showToast: Bool = false
    @State var showToastMessage = "已有组名重复，请重新命名";
    var body: some View {
        NavigationView {
            List {
                ForEach(manager.dataSource) { item in
                    Section {
                        ScreenCardView(group: item).frame(height: 150)
                            .listRowBackground(Color.white)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("应用程序")
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .alert("添加分组", isPresented: $presentEdit) {
            TextField("请输入分组名称", text: $groupName)
            
            HStack {
                Button ("cancel"){
                    
                }.foregroundColor(.red)
                
                Button("OK") {
                    if ScreenLockManager.manager.dataSource.filter({$0.name == groupName}).count > 0 {
                        showToastMessage = "已有组名重复，请重新命名";
                        showToast = true
                        groupName = ""
                        return
                    }
                    
                    if (groupName.count > 0) {
                        ScreenLockManager.saveGroup(group: ScreenLockGroup(name: groupName,
                                                                           open: false,
                                                                           count: 0,
                                                                           applicationTokens: Set<ApplicationToken>(),
                                                                           webDomainTokens: Set<WebDomainToken>(),
                                                                           activityCategoryTokens: Set<ActivityCategoryToken>()))
                        groupName = ""
                    }
                }
            }
        }
        .toast(isShow: $showToast, info: showToastMessage, duration: 1)
    }
    
    private func addItem() {
        withAnimation {
            presentEdit.toggle()
        }
    }
}


struct YLMine: View {
    @State var showPassword = false;
    var body: some View {
        NavigationView {
            List {
                Section("Application"){
                    Button("还原所有应用程序") {
                        ScreenLockManager.closeAllGroup()
                    }
                }
                
                Section {
                    Button("设置密码") {
                        showPassword.toggle()
                    }
                    Button("设置替身密码") {
                        
                    }
                } header: {
                    Text("安全")
                } footer: {
                    Text("设置替身密码后，App会伪装成记事本App")
                }
                
                
                Section {
                    Button("购买 / 恢复") {
                        
                    }
                } header: {
                    Text("Pro")
                } footer: {
                    Text("一次性升级，不限制隐藏App数量以及分组")
                }
            }
            .navigationTitle("设置")
        }
        .sheet(isPresented: $showPassword) {
            PasswordView(showPassword: $showPassword)
        }
    }
}


