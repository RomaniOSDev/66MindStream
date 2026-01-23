//
//  CollectionViewModel.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import Foundation
import Combine

class CollectionViewModel: ObservableObject {
    private var dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        dataService.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    var unlockedPlants: [Plant] {
        dataService.plants.filter { $0.isUnlocked }
    }
    
    var lockedPlants: [Plant] {
        dataService.plants.filter { !$0.isUnlocked }
    }
}
