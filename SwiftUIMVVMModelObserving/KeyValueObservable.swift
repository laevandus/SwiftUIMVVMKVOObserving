//
//  KeyValueObservable.swift
//  SwiftUIMVVMModelObserving
//
//  Created by Toomas Vahter on 02.11.2020.
//

import Foundation

// https://augmentedcode.io/2019/08/05/key-value-observing-without-nsobject-and-dynamic-in-swift/

protocol KeyValueObservable where Self: AnyObject {
    /// Stores all the added observations.
    var observationStore: ObservationStore<Self> { get }
    
    /// Sends key-value change notification to all the observers for this key path.
    func didChangeValue(for keyPath: PartialKeyPath<Self>)
    
    /// Adds observer for key path and returns observation token.
    /// – Note: Observation token is only useful if it is needed to remove observation before observer is deallocated. When observer is deallocated, then observation is removed when next key value change is handled.
    @discardableResult func addObserver<Observer: AnyObject, Value>(_ observer: Observer,
                                                                    keyPath: KeyPath<Self, Value>,
                                                                    options: Observation.Options,
                                                                    handler: @escaping (Observer, Value) -> Void) -> Observation
    
    /// Removes added observation.
    func removeObservation(_ observation: Observation)
}

extension KeyValueObservable {
    @discardableResult func addObserver<Observer: AnyObject, Value>(_ observer: Observer, keyPath: KeyPath<Self, Value>, options: Observation.Options, handler: @escaping (Observer, Value) -> Void) -> Observation {
        let observation = Observation()
        let observationHandler: (PartialKeyPath<Self>) -> Bool = { [weak self, weak observer] changedKeyPath in
            guard let self = self else { return false }
            guard let observer = observer else { return false }
            guard changedKeyPath == keyPath else { return true }
            handler(observer, self[keyPath: keyPath])
            return true
        }
        observationStore.observationInfos[observation] = observationHandler
        
        if options.contains(.initial) {
            handler(observer, self[keyPath: keyPath])
        }
        
        return observation
    }
    
    func removeObservation(_ observation: Observation) {
        observationStore.observationInfos.removeValue(forKey: observation)
    }
    
    func didChangeValue(for keyPath: PartialKeyPath<Self>) {
        observationStore.observationInfos = observationStore.observationInfos.filter({ (_, handler) -> Bool in
            return handler(keyPath)
        })
    }
}

final class ObservationStore<T> {
    fileprivate var observationInfos = [Observation: (PartialKeyPath<T>) -> Bool]()
    
    var observations: [Observation] {
        return observationInfos.map({ $0.key })
    }
    
    func removeAll() {
        observationInfos.removeAll()
    }
}

struct Observation: Hashable {
    fileprivate let identifier = UUID()
    
    struct Options: OptionSet {
        let rawValue: Int
        static let initial = Options(rawValue: 1 << 0)
    }
}
