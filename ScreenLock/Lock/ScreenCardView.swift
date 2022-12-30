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
    let cornerRadius: CGFloat = 10
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
        group.open = isOpen
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
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
                Text(group.count > 0 ? String(group.count) : "请添加")
                    .fontWeight(.bold)
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
            
            
            if ScreenLockManager.compare(selection: selection, group: group) {
                return
            }
            
            let applicationsTokens = selection.applicationTokens
            let webDomainsTokens = selection.webDomainTokens
            let categoryTokens = selection.categoryTokens
            
            ManagedSettingsStore(named: ManagedSettingsStore.Name(group.name)).clearAllSettings()
            group.count = applicationsTokens.count + webDomainsTokens.count
            group.applicationTokens = applicationsTokens
            group.webDomainTokens = webDomainsTokens
            group.activityCategoryTokens = categoryTokens;
            group.count = group.updateCount
            ScreenLockManager.saveGroup(group: group)
            
        }
        .onAppear {
            ScreenLockManager.loadLocatinData(selection: &selection, groupName: group.name)
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
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(minWidth: 80, alignment: Alignment.center)
                .zIndex(1.0)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.black)
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
