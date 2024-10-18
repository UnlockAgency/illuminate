//
//  TaskDisposeBag.swift
//
//  Created by Bas van Kuijck on 18/10/2024.
//

public protocol Taskable {
    func cancel()
}

extension Task: Taskable { }

public class TaskDisposeBag {
    private var tasks: [Taskable] = []
    
    public init() {
    }
    
    public func add(_ task: Taskable) {
        tasks.append(task)
    }
    
    private func dispose() {
        for task in tasks {
            task.cancel()
        }
        tasks.removeAll()
    }
    
    deinit {
        dispose()
    }
}

public func += (left: TaskDisposeBag, right: Taskable) {
    left.add(right)
}
