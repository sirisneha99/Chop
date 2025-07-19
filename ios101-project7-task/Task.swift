//
//  Task.swift
//

import UIKit

// The Task model
struct Task : Codable {

    // The task's title
    var title: String

    // An optional note
    var note: String?

    // The due date by which the task should be completed
    var dueDate: Date

    // Initialize a new task
    // `note` and `dueDate` properties have default values provided if none are passed into the init by the caller.
    init(title: String, note: String? = nil, dueDate: Date = Date()) {
        self.title = title
        self.note = note
        self.dueDate = dueDate
    }

    // A boolean to determine if the task has been completed. Defaults to `false`
    var isComplete: Bool = false {

        // Any time a task is completed, update the completedDate accordingly.
        didSet {
            if isComplete {
                // The task has just been marked complete, set the completed date to "right now".
                completedDate = Date()
            } else {
                completedDate = nil
            }
        }
    }

    // The date the task was completed
    // private(set) means this property can only be set from within this struct, but read from anywhere (i.e. public)
    private(set) var completedDate: Date?

    // The date the task was created
    // This property is set as the current date whenever the task is initially created.
    private(set) var createdDate: Date = Date()

    // An id (Universal Unique Identifier) used to identify a task.
    private(set) var id: String = UUID().uuidString
}

// MARK: - Task + UserDefaults
extension Task {
    
    // Key used to store tasks in UserDefaults
    static let tasksKey = "tasks"

    // Given an array of tasks, encodes them to data and saves to UserDefaults.
    static func save(_ tasks: [Task], forKey key: String = tasksKey) {
        let defaults = UserDefaults.standard
        let encodedData = try! JSONEncoder().encode(tasks)
        defaults.set(encodedData, forKey: key)
    }

    // Retrieve an array of saved tasks from UserDefaults.
    static func getTasks(forKey key: String = tasksKey) -> [Task] {
        let defaults = UserDefaults.standard
        
        if let data = defaults.data(forKey: key) {
            let decodedTasks = try! JSONDecoder().decode([Task].self, from: data)
            return decodedTasks
        } else {
            return []
        }
    }

    // Add a new task or update an existing task with the current task.
    func save() {
        // 1. Get the current array of saved tasks
        var savedTasks = Task.getTasks()
        
        // 2. Check if current task already exists (by checking for matching id)
        if let existingTaskIndex = savedTasks.firstIndex(where: { $0.id == self.id }) {
            // 3. Update existing task - remove the old one and insert updated one at same position
            savedTasks.remove(at: existingTaskIndex)
            savedTasks.insert(self, at: existingTaskIndex)
        } else {
            // 4. Add new task to the end of the array
            savedTasks.append(self)
        }
        
        // 5. Save the updated tasks array back to UserDefaults
        Task.save(savedTasks)
    }
}
