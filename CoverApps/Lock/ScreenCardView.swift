//
//  ScreenCardView.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/28.
//

import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity


struct ScreenCardView: View {
    @State var showToast = false;
    @State var selection = FamilyActivitySelection(includeEntireCategory: true)
    @ObservedObject var group :AppGroup
    let cornerRadius: CGFloat = 10
    @State var showSelctedApp = false
    var body: some View {
        VStack (spacing: 4){
            CardViewMainView(group: group,selection: $selection, isPresented:$showSelctedApp)
                .swipeActions(edge: .leading) {
                    Button(action: openOrCloseGroup) {
                        Label(group.open ? "隐藏": "开启", systemImage: "delete")
                    }.tint(.orange)
                }
            Rectangle().frame(height: 10)
                .foregroundColor(.white)
                
            HStack {
                Button(action: openOrCloseGroup) {
                    ZStack {
                        if (group.open) {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(group.open ? .white : .blue, lineWidth: 2)
                                .background(group.open ? .blue : .white)
                                .cornerRadius(cornerRadius)
                        } else {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(group.open ? .white : .blue, lineWidth: 2)
                                .background(group.open ? .blue : .white)
                        }
                        
                        HStack {
                            Image(systemName: group.open ? "eye.slash" : "eye.slash.fill")
                                .foregroundColor(group.open ? .white : .blue)
                            Text(group.open ? "已隐藏"  : "待隐藏" )
                                .foregroundColor(group.open ? .white : .blue)
                        }
                    }
                    .frame(height: 45)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                }
            }
        }
    }
    
    func openOrCloseGroup() {
        group.open.toggle()
        ScreenLockManager.save(group: group)
        if (group.count == 0) {
            self.showSelctedApp = true;
        }
    }
}

struct CardViewMainView: View {
    @ObservedObject var group :AppGroup
    @Binding var selection : FamilyActivitySelection

    @Binding var isPresented: Bool
    
    var body : some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
            HStack {
                Text(group.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text(group.count > 0 ? String(group.count) : "请添加" )
                    .foregroundColor(.blue)
                    .font(group.count > 0 ? .title : .system(size: 16))
            }
        }
        
        .swipeActions(edge: .trailing) {
            Button (role: .destructive){
                ScreenLockManager.delete(id:group.id)
                ManagedSettingsStore(named: ManagedSettingsStore.Name(group.name)).clearAllSettings()
            } label: {
                Label("删除", systemImage: "delete")
            }
        }
        .onTapGesture {
            isPresented = true
        }
        
        .familyActivityPicker(isPresented: $isPresented,
                               selection: $selection)
        .onChange(of: selection) { newSelection in
            
            if ScreenLockManager.compare(selection: selection, group: group) {
                return
            }
            
            let applicationsTokens = selection.applicationTokens
//            let webDomainsTokens = selection.webDomainTokens
            let categoryTokens = selection.categoryTokens
            
            ManagedSettingsStore(named: ManagedSettingsStore.Name(group.name)).clearAllSettings()
            group.count = applicationsTokens.count
            
            group.applicationTokens = applicationsTokens
//            group.webDomainTokens = webDomainsTokens
            group.activityCategoryTokens = categoryTokens;
            group.count = group.updateCount
            if group.count == 0 {
                group.open = false
            } else {
                group.open = group.open
            }
            ScreenLockManager.save(group: group)
        }
        .onChange(of: isPresented) { newValue in
            if (isPresented == false) {
                if group.count == 0 {
                    group.open = false
                }
            }
        }
        .onAppear {
            ScreenLockManager.loadLocatinData(selection: &selection, groupName: group.name)
        }
        
    }
}


struct ScreenCardView_Previews: PreviewProvider {
    static var previews: some View {
        List() {
            Section {
                ScreenCardView(group: AppGroup(name: "应用分组1", open: true, count: 10, creatTime: Date().timeIntervalSince1970 + 2))
                ScreenCardView(group: AppGroup(name: "应用分组1", open: true, count: 10, creatTime: Date().timeIntervalSince1970 + 3))
                ScreenCardView(group: AppGroup(name: "应用分组1", open: true, count: 0, creatTime: Date().timeIntervalSince1970 + 4))
            }
        }
    }
}



struct CardViewMainView_Previews: PreviewProvider {
    static var previews: some View {
        CardViewMainView(group: AppGroup(name: "应用分组1", open: true, count: 0, creatTime: Date().timeIntervalSince1970 + 4),
                         selection: .constant(FamilyActivitySelection(includeEntireCategory: true)),
                         isPresented: .constant(true)
        )
    }
}
