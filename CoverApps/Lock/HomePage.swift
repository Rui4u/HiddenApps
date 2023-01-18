//
//  Home.swift
//  CoverApps
//
//  Created by sharui on 2023/1/18.
//

import SwiftUI


class AddGroupModel: ObservableObject {
    @Published var showToast: Bool
    @Published var groupName: String
    @Published var errorMessage: String
    
    init(showToast: Bool = false, groupName: String = "应用分组", errorMessage: String = "已有组名重复，请重新命名") {
        self.showToast = showToast
        self.groupName = groupName
        self.errorMessage = errorMessage
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}

struct HomePage: View {
    @ObservedObject var manager: ScreenLockManager = ScreenLockManager.manager
    @StateObject var addGroupModel = AddGroupModel()
    @State var presentEdit: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(manager.dataSource) { item in
                    Section {
                        ScreenCardView(group: item)
                            .listRowBackground(Color.white)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("应用程序" )
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .alert("添加分组", isPresented: $presentEdit) {
            AddGroupAlert(groupName: $addGroupModel.groupName, show: $addGroupModel.showToast, error: $addGroupModel.errorMessage)
        }
        .toast(isShow: $addGroupModel.showToast, info: addGroupModel.errorMessage, duration: 1)
    }
    
    private func addItem() {
        withAnimation {
            presentEdit.toggle()
        }
    }
}


struct AddGroupAlert: View {
    @Binding var groupName: String
    @Binding var show: Bool
    @Binding var error: String
    
    var body: some View {
        TextField("请输入分组名称", text: $groupName)
        HStack {
            Button ("cancel"){
                
            }.foregroundColor(.red)
            
            Button("OK") {
                if ScreenLockManager.manager.dataSource.filter({$0.name == groupName}).count > 0 {
                    error = "已有组名重复，请重新命名";
                    show = true
                    groupName = ""
                    return
                }
                
                if (groupName.count > 0) {
                    ScreenLockManager.saveGroup(group: ScreenLockGroup(name: groupName,
                                                                       open: false,
                                                                       count: 0))
                    groupName = ""
                }
            }
        }
    }
}