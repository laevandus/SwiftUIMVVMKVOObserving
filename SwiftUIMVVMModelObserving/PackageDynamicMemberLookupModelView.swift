//
//  PackageDynamicMemberLookupModelView.swift
//  SwiftUIMVVMModelObserving
//
//  Created by Toomas Vahter on 02.11.2020.
//

import Combine
import SwiftUI

// MARK: View

struct PackageDynamicMemberLookupModelView: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.modelDescription)
            Button("Update first name") {
                let newValue = String("absdefghij".shuffled())
                print("Will set to", newValue)
                viewModel.recipient.firstName = newValue
            }
        }
    }
}

// MARK: Model

extension PackageDynamicMemberLookupModelView {
    final class Package: KeyValueObservable {
        let observationStore = ObservationStore<Package>()
        
        var recipient = FullName() {
            didSet {
                didChangeValue(for: \Package.recipient)
            }
        }
        
        // Other properties…
    }
}

// MARK: View Model

extension PackageDynamicMemberLookupModelView {
    @dynamicMemberLookup
    final class ViewModel: ObservableObject {
        private var package: Package
        private var cancellables = [AnyCancellable]()
        
        init(package: Package) {
            self.package = package
            
            // Model -> ViewModel
            // Custom observer method, see `KeyValueObservable`
            package.addObserver(self, keyPath: \.recipient, options: []) { [weak self] _, newValue in
                // More correct would be to support will change in `KeyValueObservable`
                self?.objectWillChange.send()
            }
        }
        
        subscript<T>(dynamicMember keyPath: WritableKeyPath<Package, T>) -> T {
            get {
                return package[keyPath: keyPath]
            }
            set {
                package[keyPath: keyPath] = newValue
            }
        }
        
        var modelDescription: String {
            return String(describing: package.recipient)
        }
    }
}


struct PackageDynamicMemberLookupModelView_Previews: PreviewProvider {
    static var previews: some View {
        PackageDynamicMemberLookupModelView(viewModel: PackageDynamicMemberLookupModelView.ViewModel(package: PackageDynamicMemberLookupModelView.Package()))
    }
}
