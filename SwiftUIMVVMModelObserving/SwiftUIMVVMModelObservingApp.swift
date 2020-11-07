//
//  SwiftUIMVVMModelObservingApp.swift
//  SwiftUIMVVMModelObserving
//
//  Created by Toomas Vahter on 31.10.2020.
//

import SwiftUI

@main
struct SwiftUIMVVMModelObservingApp: App {
    var body: some Scene {
        WindowGroup {
            PackageKVOModelView(viewModel: PackageKVOModelView.ViewModel(package: PackageKVOModelView.Package()))
            
            //PackageCombineModelView(viewModel: PackageCombineModelView.ViewModel(package: PackageCombineModelView.Package()))
            
            //PackageObservableModelView(viewModel: PackageObservableModelView.ViewModel(package: PackageObservableModelView.Package()))
            
            //PackageDynamicMemberLookupModelView(viewModel: PackageDynamicMemberLookupModelView.ViewModel(package: PackageDynamicMemberLookupModelView.Package()))
        }
    }
}
