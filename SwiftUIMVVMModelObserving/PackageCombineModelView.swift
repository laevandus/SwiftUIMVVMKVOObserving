//
//  PackageCombineModelView.swift
//  SwiftUIMVVMModelObserving
//
//  Created by Toomas Vahter on 02.11.2020.
//

import Combine
import SwiftUI

// MARK: View

struct PackageCombineModelView: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        Form {
            TextField("First name", text: $viewModel.firstName)
            Text(viewModel.modelDescription)
        }
    }
}

// MARK: Model

extension PackageCombineModelView {
    final class Package {
        @Published var recipient = FullName()
        
        // Other properties…
    }
}

struct FullName {
    var firstName: String = "A"
    var lastName: String = "B"
}

// MARK: View Model

extension PackageCombineModelView {
    final class ViewModel: ObservableObject {
        private let package: Package
        private var cancellables = [AnyCancellable]()
        
        init(package: Package) {
            self.package = package
            // Model -> ViewModel
            package.$recipient
                .map(\.firstName)
                .assign(to: &$firstName)
            
            // ViewModel -> Model
            $firstName
                .dropFirst()
                .removeDuplicates()
                .assign(to: \.recipient.firstName, on: package)
                .store(in: &cancellables)
        }
        
        @Published var firstName: String = ""
        
        var modelDescription: String {
            return String(describing: package.recipient)
        }
    }
}


struct PackageCombineModelView_Previews: PreviewProvider {
    static var previews: some View {
        PackageCombineModelView(viewModel: PackageCombineModelView.ViewModel(package: PackageCombineModelView.Package()))
    }
}
