//
//  LegacyKeyValueObservationCleanerWrapper.swift
//  TextInputFilter
//
//  Created by Fabio Rodella on 27/08/18.
//  Copyright © 2018 Rodels. All rights reserved.
//

import Foundation

/// This class works around an interesting situation involving KVO in Swift with iOS < 11.
/// More details in these links:
/// https://bugs.swift.org/browse/SR-5816
/// https://stackoverflow.com/questions/50058609/ios-10-nskeyvalueobservation-crash-on-deinit
class LegacyKeyValueObservationCleanerWrapper: NSObject {
    
    weak var weakObserver: NSObject?
    unowned(unsafe) let unsafeObserver: NSObject
    let observation: NSKeyValueObservation
    
    init(observation: NSKeyValueObservation, observer: NSObject) {
        self.observation = observation
        self.weakObserver = observer
        self.unsafeObserver = observer
    }
    
    deinit {
        // If weakObserver is nil at this point, it means we'll need to manually remove the observer using
        // the unsafe reference, which will still be around.
        if weakObserver == nil {
            unsafeObserver.removeObserver(observation, forKeyPath: "delegate")
        }
    }
}
