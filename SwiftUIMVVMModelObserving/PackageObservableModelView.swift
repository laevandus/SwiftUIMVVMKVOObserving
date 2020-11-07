//
//  PackageObservableModelView.swift
//  SwiftUIMVVMModelObserving
//
//  Created by Toomas Vahter on 02.11.2020.
//

import Combine
import SwiftUI

// MARK: View

struct PackageObservableModelView: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        Form {
            TextField("First name", text: viewModel.firstName)
            Text(viewModel.modelDescription)
        }
    }
}

// MARK: Model

extension PackageObservableModelView {
    final class Package: ObservableObject {
        @Published var recipient = FullName()
        
        // Other properties…
    }
}

// MARK: View Model

extension PackageObservableModelView {
    final class ViewModel: ObservableObject {
        private let package: Package
        private var cancellables = [AnyCancellable]()
        
        init(package: Package) {
            self.package = package
            
            address.objectWillChange.sink { [unowned self] in
                self.objectWillChange.send()
            }.store(in: &cancellables)
            
            // Model -> ViewModel
            package.objectWillChange.sink { [unowned self] in
                self.objectWillChange.send()
            }.store(in: &cancellables)
        }
        
        var firstName: Binding<String> {
            return Binding<String>(get: {
                return self.package.recipient.firstName
            }, set: { newValue in
                self.package.recipient.firstName = newValue
            })
        }
        
        var modelDescription: String {
            return String(describing: package.recipient)
        }
    }
}


struct PackageObservableModelView_Previews: PreviewProvider {
    static var previews: some View {
        PackageObservableModelView(viewModel: PackageObservableModelView.ViewModel(package: PackageObservableModelView.Package()))
    }
}
