//
//  MainView.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/27.
//

import SwiftUI
import FamilyControls

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
        NavigationView { //整体设置，下级页面不会在出现底部tabbar
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
    var body: some View {
        List(manager.dataSource) { item in
            Section {
                ScreenCardView(group: item).frame(height: 150)
                    .listRowBackground(Color.white)
            }
        }
        
        .toolbar {
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .alert("添加分组", isPresented: $presentEdit) {
            TextField("请输入分组名称", text: $groupName)
                
            HStack {
                Button ("cancel"){
                    
                }.foregroundColor(.red)
                
                Button("OK") {
                    if (groupName.count > 0) {
                        ScreenLockManager.saveGroup(group: ScreenLockGroup(name: groupName, open: true, count: 0))
                        groupName = ""
                    }
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            presentEdit.toggle()
        }
    }
}


struct YLMine: View {
    var body: some View {
        Text("YLMine")
    }
}


