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
    @ObservedObject var group :ScreenLockGroup
    var body: some View {
        ZStack {
            VStack {
                CardViewMainView(group: group,selection: $selection)
                Spacer(minLength:30)
                HStack {
                    Button {
                        group.open.toggle()
                        ScreenLockManager.saveGroup(group: group)
                        hiddenIsOpen(isOpen: group.open, name: group.name)
                    } label: {
                        ZStack {
                            if (group.open) {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(group.open ? .white : .blue, lineWidth: 2)
                                    .background(group.open ? .blue : .white)
                                    .cornerRadius(20)
                            } else {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(group.open ? .white : .blue, lineWidth: 2)
                                    .background(group.open ? .blue : .white)
                            }
                                
                            HStack {
                                Image(systemName: group.open ? "eye.slash" : "eye.slash.fill")
                                    .foregroundColor(group.open ? .white : .blue)
                                Text(group.open ? "已隐藏" : "待隐藏")
                                    .foregroundColor(group.open ? .white : .blue)
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    }
                }
            }
        }
    }
    
    func hiddenIsOpen(isOpen: Bool, name:String) {
        if (isOpen) {
            if let find = ScreenLockManager.find(Set<ApplicationToken>.self, key: "applicationToken" + "_" + "\(group.name)") {
                ManagedSettingsStore(named: ManagedSettingsStore.Name(name)).application.blockedApplications = Set(find.map({Application(token: $0)}))
            }
            
            if let find = ScreenLockManager.find(Set<WebDomainToken>.self, key: "domainsToken" + "_" + "\(group.name)") {
                ManagedSettingsStore(named: ManagedSettingsStore.Name(name)).shield.webDomains = Set(find)
            }
            
        } else {
            ManagedSettingsStore(named: ManagedSettingsStore.Name(name)).clearAllSettings()
        }

    }
    
}

struct CardViewMainView: View {
    @ObservedObject var group :ScreenLockGroup
    @Binding var selection : FamilyActivitySelection

    @State var isPresented = false
    
    var body : some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
            HStack {
                Text(group.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
                Text(group.count > 0 ? String(group.count) : "请添加")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                group.open.toggle()
                ScreenLockManager.saveGroup(group: group)
            } label: {
                if group.open {
                    Label("Read", systemImage: "envelope.open")
                } else {
                    Label("Unread", systemImage: "envelope.badge")
                }
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
        }.familyActivityPicker(isPresented: $isPresented,
                               selection: $selection)
        .onChange(of: selection) { newSelection in
            
            var isSame = 0;
            if let find = ScreenLockManager.find(Set<ApplicationToken>.self, key: "applicationToken" + "_" + "\(group.name)") {
                if selection.applicationTokens == find {
                    isSame = isSame + 1
                }
                
            }
            
            if let find = ScreenLockManager.find(Set<WebDomainToken>.self, key: "domainsToken" + "_" + "\(group.name)") {
                if selection.webDomainTokens == find {
                    isSame = isSame + 1
                }
            }
            
            if let find = ScreenLockManager.find(Set<ActivityCategoryToken>.self, key: "categoryTokens" + "_" + "\(group.name)") {
                if selection.categoryTokens == find {
                    isSame = isSame + 1
                }
            }
            if isSame == 3 {
                return
            }
            
            
            ManagedSettingsStore(named: ManagedSettingsStore.Name(group.name)).clearAllSettings()
            group.open = false;
            
//            let applications = selection.applications
//            let webDomains = selection.webDomains
//            ManagedSettingsStore(named: .social).application.blockedApplications = applications
//            ManagedSettingsStore(named: .social).shield.webDomains = Set(webDomains.map({$0.token!}))
            
            
            let applicationsTokens = selection.applicationTokens
            let webDomainsTokens = selection.webDomainTokens
            let categoryTokens = selection.categoryTokens
            
            group.count = applicationsTokens.count + webDomainsTokens.count
            
            ScreenLockManager.save(applicationsTokens, key: "applicationToken" + "_" + "\(group.name)")
            ScreenLockManager.save(webDomainsTokens, key: "domainsToken" + "_" + "\(group.name)")
            ScreenLockManager.save(categoryTokens, key: "categoryTokens" + "_" + "\(group.name)")
            ScreenLockManager.saveGroup(group: group)
            
            
        }
        .onAppear {
            
            if let find = ScreenLockManager.find(Set<ApplicationToken>.self, key: "applicationToken" + "_" + "\(group.name)") {
                selection.applicationTokens = find
            }
            
            if let find = ScreenLockManager.find(Set<WebDomainToken>.self, key: "domainsToken" + "_" + "\(group.name)") {
                selection.webDomainTokens = find
            }
            
            if let find = ScreenLockManager.find(Set<ActivityCategoryToken>.self, key: "categoryTokens" + "_" + "\(group.name)") {
                selection.categoryTokens = find
            }
        }
    }
}

struct TWToastView: View {
    @Binding var isShow: Bool
    let info: String
    @State private var isShowAnimation: Bool = true
    @State private var duration : Double
    
    init(isShow:Binding<Bool>,info: String = "", duration:Double = 1.0) {
        self._isShow = isShow
        self.info = info
        self.duration = duration
    }
    
    var body: some View {
        ZStack {
            Text(info)
                .font(Font.title3)
                .foregroundColor(.white)
                .frame(minWidth: 80, alignment: Alignment.center)
                .zIndex(1.0)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.black)
                        .opacity(0.6)
                )
            
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                isShowAnimation = false
            }
        }
        .padding()
        .opacity(isShowAnimation ? 1 : 0)
        .animation(.easeIn(duration: 0.8))
        .edgesIgnoringSafeArea(.all)
        .onChange(of: isShowAnimation) { e in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.isShow = false
            }
        }
    }
}

extension View {
    func toast(isShow:Binding<Bool>, info:String = "",  duration:Double = 1.0) -> some View {
        ZStack {
            self
            if isShow.wrappedValue {
                TWToastView(isShow:isShow, info: info, duration: duration)
            }
        }
     }
}
