//
//  ThreadSafeDictionary.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 01/03/2022.
//  Copyright © 2022 threesidedcube. All rights reserved.
//

import Foundation

/// A dictionary whose accesses are made thread safe by using a concurrent queue with a barrier.
///
/// # Source:
/// https://github.com/iThink32/Thread-Safe-Dictionary
class ThreadSafeDictionary<V: Hashable,T>: Collection {

    private var dictionary: [V: T]

    private let concurrentQueue = DispatchQueue(
        label: "ThreadSafeDictionary.Barrier.Queue",
        attributes: .concurrent
    )

    var startIndex: Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.startIndex
        }
    }

    var endIndex: Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.endIndex
        }
    }

    init(dict: [V: T] = [V:T]()) {
        self.dictionary = dict
    }

    func index(after i: Dictionary<V, T>.Index) -> Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.index(after: i)
        }
    }

    subscript(key: V) -> T? {
        set(newValue) {
            self.concurrentQueue.async(flags: .barrier) {[weak self] in
                self?.dictionary[key] = newValue
            }
        }
        get {
            self.concurrentQueue.sync {
                return self.dictionary[key]
            }
        }
    }

    subscript(index: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element {
        self.concurrentQueue.sync {
            return self.dictionary[index]
        }
    }

    func removeValue(forKey key: V) {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }

    func removeAll() {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeAll()
        }
    }
}
