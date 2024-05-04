//
//  PlacemarksVC.swift
//  WakeMeUp
//
//  Created by Selçuk İleri on 13.11.2023.
//

import UIKit
import CoreData

class PlacemarksVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
        
    var titleArray = [String]()
    var idArray = [UUID]()
    var chosenTitle = ""
    var chosenTitleId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        getData()
        configure()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    func configureTableView(){
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.backgroundColor = .systemBackground
        tableView.register(PlacemarksCell.self, forCellReuseIdentifier: PlacemarksCell.reuseID)
    }
    
    func configure(){
        view.backgroundColor = .systemBackground
        let addButton = UIBarButtonItem(image: .add, style: .done, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func addTapped(){
        chosenTitle = ""
        let mapsVC = MapsVC()
        navigationController?.pushViewController(mapsVC, animated: true)
    }
    
    @objc func getData(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    tableView.reloadData()
                }
            }
            } catch {
                makeAlert(title: "Uyarı", message: error.localizedDescription)
            }
            
        
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlacemarksCell.reuseID, for: indexPath) as! PlacemarksCell
        cell.nameText.text = titleArray[indexPath.row]
        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]
        chosenTitleId = idArray[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        let destVC = MapsVC()
        destVC.selectedTitle = chosenTitle
        destVC.selectedTitleId = chosenTitleId
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear 
        return footerView
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                titleArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: .left)
                                self.tableView.reloadData()
                                do {
                                    try context.save()
                                } catch {
                                    makeAlert(title: "Hata", message: error.localizedDescription)
                                }
                                break
                            }
                        }
                    }
                }
            } catch {
                makeAlert(title: "Uyarı", message: error.localizedDescription)
            }
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}
