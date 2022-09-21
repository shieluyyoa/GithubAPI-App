//
//  FavouritesListVC.swift
//  GithubFollowers
//
//  Created by Oscar Lui on 24/7/2022.
//

import UIKit

class FavouritesListVC: GFDataLoadingVC {
    
    
    let tableView = UITableView()
    var favourites = [Follower]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavourites()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
        
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favourites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.removeExcessCells()
        
        tableView.register(FavouriteCell.self, forCellReuseIdentifier: FavouriteCell.idenitifier)
        
        
    }
    
    func getFavourites() {
        PersistentManager.retrieveFavourites { result in
            switch result {
            case .success(let favourites):
                if favourites.isEmpty {
                    showEmptyStateView(with: "No Favourites 😥")
                } else {
                    self.favourites = favourites
                    tableView.reloadData()
                    view.bringSubviewToFront(tableView)
                }
                
            case .failure(let error):
                self.presentGFAlert(title: "Something went erro", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }


}

extension FavouritesListVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavouriteCell.idenitifier) as! FavouriteCell
        let favourite = favourites[indexPath.row]
        cell.set(favourite: favourite)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favourite = favourites[indexPath.row]
        let followerListVC = FollowerListVC(username: favourite.login)
 
        
        navigationController?.pushViewController(followerListVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        PersistentManager.updateFavouriteData(favourite: favourites[indexPath.row], actionType: .remove) { error in
            guard let error = error else {
                favourites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            
            presentGFAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
        }
        
       
        	
    }
    
    
}
