//
//  Coordinator.swift
//  CoverApps
//
//  Created by sharui on 2023/1/18.
//
import SwiftUI

class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func pop() {
        path.removeLast()
    }
}
