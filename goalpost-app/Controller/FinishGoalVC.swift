//
//  FinishGoalVC.swift
//  goalpost-app
//
//  Created by eslam dweeb on 3/24/18.
//  Copyright © 2018 eslam dweeb. All rights reserved.
//

import UIKit
import CoreData

class FinishGoalVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var createGoalBtn: UIButton!
    @IBOutlet weak var pointTextField: UITextField!
    
    var goalDescription: String!
    var gaolType: GoalType!
    
    func initData(description: String, type: GoalType){
        self.goalDescription = description
        self.gaolType = type
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createGoalBtn.bindToKeyboard()
        pointTextField.delegate = self
    }

    @IBAction func createGoalBtnWasPressed(_ sender: Any) {
        if pointTextField.text != "" {
            save(completion: { (complete) in
                if complete{
                    dismiss(animated: true, completion: nil)
                }
            })
        }
        
    }
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        dismissDetail()
    }
    func save(completion: (_ finished: Bool) -> ()){
        guard let managedContext = appDelegete?.persistentContainer.viewContext else{return}
        let goal = Goal(context: managedContext)
        
        goal.goalDescription = goalDescription
        goal.goalType = gaolType.rawValue
        goal.goalCompletionValue = Int32(pointTextField.text!)!
        goal.goalProgress = Int32(0)
        
        do{
            try managedContext.save()
            completion(true)
        }catch{
            debugPrint("Could not sve: \(error.localizedDescription)")
            completion(false)
        }
    }
}
