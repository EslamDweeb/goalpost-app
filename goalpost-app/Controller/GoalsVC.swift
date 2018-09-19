//
//  GoalVC.swift
//  goalpost-app
//
//  Created by eslam dweeb on 3/21/18.
//  Copyright © 2018 eslam dweeb. All rights reserved.
//

import UIKit
import CoreData

let appDelegete = UIApplication.shared.delegate as? AppDelegate

class GoalsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var undoView: UIView!
    
    var goals: [Goal] = []
    var manager = UndoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCoreDataObjects()
        tableView.reloadData()
    }
    
    func fetchCoreDataObjects() {
        self.fetch { (complete) in
            if complete{
                if goals.count >= 1 {
                    tableView.isHidden = false
                }else{
                    tableView.isHidden = true
                }
            }
        }
    }
    
    @IBAction func addGoalBtnWasPressed(_ sender: Any) {
        guard let createGoalVC = storyboard?.instantiateViewController(withIdentifier: "CreateGoalVC") else{ return}
        presentDetail(createGoalVC)
    }
    
    @IBAction func undoBtnWasPressed(_ sender: Any) {
       manager.undo()
    }
    
}

extension GoalsVC : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell") as? GoalCell else {return UITableViewCell()}
        let goal = goals[indexPath.row]
        cell.configureCell(goal: goal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            self.undoView.isHidden = false
            self.removeGoal(atIndexPath: indexPath)
            self.fetchCoreDataObjects()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.manager.registerUndo(withTarget: self, selector: #selector(self.undoRemove), object: indexPath)

            
        }
        let addAction = UITableViewRowAction(style: .normal, title: "ADD 1") { (rowAction, indexPath) in
            self.setProgress(atIndexPath: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        addAction.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        
        return [deleteAction, addAction]
    }
    @objc func undoRemove(atIndexPath indexPath: IndexPath){
        self.undoView.isHidden = true
        self.fetchCoreDataObjects()
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
}

extension GoalsVC {
    
    func setProgress(atIndexPath indexPath: IndexPath){
        guard let managedContext = appDelegete?.persistentContainer.viewContext else{return}
        let chosenGoal = goals[indexPath.row]
        
        if chosenGoal.goalProgress < chosenGoal.goalCompletionValue {
            chosenGoal.goalProgress += 1
        }else{
            return
        }
        
        do{
            try managedContext.save()
        }catch{
            debugPrint("could not set progress:\(error.localizedDescription )")
        }
    }
    
    func removeGoal(atIndexPath indexPath: IndexPath){
        guard let managedContext = appDelegete?.persistentContainer.viewContext else{return}
        managedContext.delete(goals[indexPath.row])
        do{
            try managedContext.save()
        }catch{
            debugPrint("could not remove: \(error.localizedDescription)")
        }
        manager.registerUndo(withTarget: self, selector: #selector(undoRemove), object: indexPath)
    }
    
    func fetch(completion: (_ complete: Bool) -> ()) {
        guard let managedContext = appDelegete?.persistentContainer.viewContext else{return}
        
        let fetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
        do{
            goals = try managedContext.fetch(fetchRequest)
            completion(true)
        }catch{
            debugPrint("could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
    
}
















