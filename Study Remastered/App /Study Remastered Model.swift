//
//  Study Remastered Model.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/14/22.
//

import Foundation
import SwiftUI

struct StudyRemasteredModel {
}

class StudyRemasteredViewModel: ObservableObject {
    
    
    @Published var model: StudyRemasteredModel
    
    @Published var calculatorIsActive = false 
    lazy var activeCalculatorHandler = EquationTextHandler()
    var activeCardText = CardTextViewModel("")
    
    init( _ model: StudyRemasteredModel ) {
        self.model = model
    }
}

let appViewModel = StudyRemasteredViewModel(StudyRemasteredModel())
