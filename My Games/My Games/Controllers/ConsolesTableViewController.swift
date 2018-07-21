//
//  ConsolesTableViewController.swift
//  My Games
//
//  Created by Aluno on 21/07/18.
//  Copyright © 2018 CESAR School. All rights reserved.
//

import UIKit
import CoreData

class ConsolesTableViewController: UITableViewController {

    var fetchedResultController:NSFetchedResultsController<Console>!
    let searchController = UISearchController(searchResultsController: nil)
    
    var consolesManager = ConsolesManager.shared
    var label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Vc não tem consoles cadastrados"
        label.textAlignment = .center
    
        // altera comportamento default que adicionava background escuro sobre a view principal
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        
        navigationItem.searchController = searchController
        
        // usando extensions
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        
        loadConsoles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // se ocorrer mudancas na entidade Console, a atualização automatica não irá ocorrer porque nosso NSFetchResultsController esta monitorando a entidade Game. Caso tiver mudanças na entidade Console precisamos atualizar a tela com a tabela de alguma forma: reloadData :)
        tableView.reloadData()
    }
    
    func loadConsoles(filtering: String = "") {
        
        // Coredata criou na classe model uma funcao para recuperar o fetch request
        let fetchRequest: NSFetchRequest<Console> = Console.fetchRequest()
        
        // definindo criterio da ordenacao de como os dados serao entregues
        let consoleSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [consoleSortDescriptor]
        
        
        if !filtering.isEmpty {
            // usando predicate: conjunto de regras para pesquisas
            // contains [c] = search insensitive (nao considera letras identicas)
            let predicate = NSPredicate(format: "name contains [c] %@", filtering)
            fetchRequest.predicate = predicate
        }
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        consolesManager.loadConsoles(with: context)
        tableView.reloadData()
    }

    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let count = fetchedResultController?.fetchedObjects?.count ?? 0
        tableView.backgroundView = count == 0 ? label : nil
        return count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let console = fetchedResultController.fetchedObjects?[indexPath.row] else {
            return cell
        }
        
        cell.textLabel?.text = console.name
        cell.imageView?.image = console.icon as? UIImage ?? UIImage(named: "noCover")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard let console = fetchedResultController.fetchedObjects?[indexPath.row] else {return}
            context.delete(console)
            
            do {
                try context.save()
            } catch  {
                print(error.localizedDescription)
            }
        }
    }
 

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "consoleSegue" {
            print("consoleSegue")
            let vc = segue.destination as! ConsoleDetailsViewController
            
            if let consoles = fetchedResultController.fetchedObjects {
                vc.console = consoles[tableView.indexPathForSelectedRow!.row]
            }
            
        } else if segue.identifier! == "newConsoleSegue" {
            print("newConsoleSegue")
            
        }
    }
}

extension ConsolesTableViewController: NSFetchedResultsControllerDelegate {
    
    // sempre que algum objeto for modificado esse metodo sera notificado
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        default:
            tableView.reloadData()
        }
    }
}

extension ConsolesTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadConsoles()
        tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadConsoles(filtering: searchBar.text!)
        tableView.reloadData()
    }
}

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let console = consolesManager.consoles[indexPath.row]
//        showAlert(with: console)
//
//        // deselecionar atual cell
//        tableView.deselectRow(at: indexPath, animated: false)
//    }



/*
 // Override to support conditional editing of the table view.
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the specified item to be editable.
 return true
 }
 */

/*
 // Override to support editing the table view.
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
 if editingStyle == .delete {
 // Delete the row from the data source
 tableView.deleteRows(at: [indexPath], with: .fade)
 } else if editingStyle == .insert {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
 
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the item to be re-orderable.
 return true
 }
 */

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 
 func showAlert(with console: Console?) {
 let title = console == nil ? "Adicionar" : "Editar"
 let alert = UIAlertController(title: title + " plataforma", message: nil, preferredStyle: .alert)
 
 alert.addTextField(configurationHandler: { (textField) in
 textField.placeholder = "Nome da plataforma"
 
 if let name = console?.name {
 textField.text = name
 }
 })
 
 alert.addAction(UIAlertAction(title: title, style: .default, handler: {(action) in
 let console = console ?? Console(context: self.context)
 console.name = alert.textFields?.first?.text
 do {
 try self.context.save()
 self.loadConsoles()
 } catch {
 print(error.localizedDescription)
 }
 }))
 
 alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
 alert.view.tintColor = UIColor(named: "second")
 
 present(alert, animated: true, completion: nil)
 }
 */

