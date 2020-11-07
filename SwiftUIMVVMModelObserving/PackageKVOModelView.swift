//
//  PackageKVOModelView.swift
//  SwiftUIMVVMModelObserving
//
//  Created by Toomas Vahter on 02.11.2020.
//

import Combine
import SwiftUI

// MARK: View

struct PackageKVOModelView: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        Form {
            TextField("First name", text: $viewModel.firstName)
            Text(viewModel.modelDescription)
        }
    }
}

// MARK: Model

extension PackageKVOModelView {
    final class Package: NSObject {
        @objc dynamic var recipient = FullNameNSObject()
    }
}

final class FullNameNSObject: NSObject {
    @objc dynamic var firstName: String = "A"
    @objc dynamic var lastName: String = "B"
}

// MARK: View Model

extension PackageKVOModelView {
    final class ViewModel: ObservableObject {
        private let package: Package
        private var cancellables = [AnyCancellable]()

        init(package: Package) {
            self.package = package
            // Model -> View Model
            package.publisher(for: \.recipient.firstName).assign(to: &$firstName)
            
            // View Model -> Model
            $firstName.dropFirst().removeDuplicates().assign(to: \.recipient.firstName, on: package).store(in: &cancellables)
        }
        
        @Published var firstName: String = ""
        
        var modelDescription: String {
            return package.recipient.firstName + " " + package.recipient.lastName
        }
    }
}

struct PackageKVOModelView_Previews: PreviewProvider {
    static var previews: some View {
        PackageKVOModelView(viewModel: PackageKVOModelView.ViewModel(package: PackageKVOModelView.Package()))
    }
}
