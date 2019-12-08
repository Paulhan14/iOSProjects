//
//  DataSource.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/20/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol DataSourceCellConfigurer {
    func configureCell(_ cell:UITableViewCell, withObject object:NSManagedObject) -> Void
}

class DataSource: NSObject {
    var tableView : UITableView! {
        didSet {
            fetchedResultsController.delegate = self
        }
    }
    let dataManager = DataManager.theManager
    var delegate : DataSourceCellConfigurer?
    let fetchRequest : NSFetchRequest<NSFetchRequestResult>
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>
    
    init(entity: String, sortKeys:[String],  predicate: NSPredicate?, sectionNameKeyPath: String?) {
        let sortDescriptors : [NSSortDescriptor] = {
            var _sortDescriptors = [NSSortDescriptor]()
            for key in sortKeys {
                let descriptor = NSSortDescriptor(key: key, ascending: true)
                _sortDescriptors.append(descriptor)
            }
            return _sortDescriptors
        }()
        fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataManager.context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        var error: NSError? = nil
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(String(describing: error)), \(error!.userInfo)")
        }
    }
}

extension DataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = self.fetchedResultsController.sections?.count ?? 0
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let managedObject = objectAtIndexPath(indexPath)
        let cellIdentifier = Constant.CellIdentifier.myPostCell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        delegate?.configureCell(cell, withObject: managedObject)
        return cell
    }
    
    func objectAtIndexPath(_ indexPath: IndexPath) -> NSManagedObject {
        let obj = fetchedResultsController.object(at: indexPath) as! NSManagedObject
        return obj
    }
}

extension DataSource: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
}
