//
//  FollowerListVC.swift
//  GithubFollowers
//
//  Created by Oscar Lui on 26/7/2022.
//

import UIKit

class FollowerListVC: GFDataLoadingVC {
    
    enum Section {
        case main
    }
    
    
    var username: String!
    var followers = [Follower]()
    var filterdFollowers = [Follower]()
    var page = 1
    var hasMoreFollowers = true
    var isSearching = false
    var isLoadingMoreFollowers = false
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section,Follower>!
    
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username = username
        title = username
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureSearchController()
        configureViewController()
        getFollower(username: username, page: 1)
        configureDataSource()
        collectionView.delegate = self
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createThreeColumnFlowLayout())
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.idenitifier)
        
    }
    
    func createThreeColumnFlowLayout() -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 12
        let minimumItemSpacing: CGFloat = 10
        let availableWidth = width - (padding * 2) - (minimumItemSpacing * 2)
        let itemWidth = availableWidth / 3
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowlayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
        
        
        return flowlayout
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    func getFollower(username: String, page: Int) {
        showLoadingView()
        isLoadingMoreFollowers = true
        
        Task {
            do {
                let followers = try await NetworkManager.shared.getFollowers(for:username,page:page)
                updateFollowers(with: followers)
                dismissLoadingView()
                isLoadingMoreFollowers = false
            } catch {
                if let gfError = error as? GFError {
                    presentGFAlert(title: "Error", message: gfError.rawValue, buttonTitle: "Ok")
                } else {
                    presentDefaultError()
                }
                
                dismissLoadingView()
                isLoadingMoreFollowers = false
            }
        }
        
//        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
//
//            guard let strongSelf = self else {
//                return
//            }
//
//            strongSelf.dismissLoadingView()
//
//            switch result {
//
//            case .success(let followers):
//                strongSelf.updateFollowers(with: followers)
//
//
//            case .failure(let error):
//                strongSelf.presentGFAlertOnMainThread(title: "Error", message: error.rawValue, buttonTitle: "Ok")
//            }
//        }
        
    }
    
    func updateFollowers(with followers:[Follower]) {
        
        if followers.count < 100 {
            self.hasMoreFollowers = false
        }
        self.followers.append(contentsOf: followers)
        
        if self.followers.isEmpty {
            let message = "This user doesn't have any followrs. Go Follow them ."
            DispatchQueue.main.async {
                self.showEmptyStateView(with: message)
            }
            return
        }
        DispatchQueue.main.async {
            self.navigationItem.searchController?.searchBar.isHidden = false
        }
        self.updateData(on: self.followers)
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section,Follower>(collectionView: collectionView, cellProvider: { collectionView, indexPath, follower in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.idenitifier, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            
            return cell
        })
        
    }
    
    func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section,Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        
    }
    
    @objc func addButtonTapped() {
        showLoadingView()
        
        
        Task {
            do {
                let user = try await NetworkManager.shared.getUserInfo(for: username)
                addUserToFavourites(user: user)
                dismissLoadingView()
            } catch {
                if let gfError = error as? GFError {
                    presentGFAlert(title: "Error", message: gfError.rawValue, buttonTitle: "Ok")
                } else {
                    presentDefaultError()
                }
            }
        }
        
        
//        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
//            guard let strongSelf = self else {
//                return
//            }
//
//            strongSelf.dismissLoadingView()
//
//            switch result {
//            case .success(let user):
//                let favourite = Follower(login: user.login, avatarUrl: user.avatarUrl)
//                PersistentManager.updateFavouriteData(favourite: favourite, actionType: .add) { error in
//                    guard let error = error else {
//                        presentGFAlertOnMainThread(title: "Success", message: "You successfully favourited this user.", buttonTitle: "Congrats")
//                        return
//                    }
//
//                        presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Sad")
//
//                }
//
//            case .failure(let error):
//                    presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
//            }
//        }
    }
    
    
    func addUserToFavourites(user: User) {
        let favourite = Follower(login: user.login, avatarUrl: user.avatarUrl)
        PersistentManager.updateFavouriteData(favourite: favourite, actionType: .add) { error in
            guard let error = error else {
                presentGFAlert(title: "Success", message: "You successfully favourited this user.", buttonTitle: "Congrats")
                return
            }
            
            presentGFAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Sad")

        }
    }
}

extension FollowerListVC: UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        
        if offsetY > contentHeight - height {
            guard hasMoreFollowers, !isLoadingMoreFollowers else {
                return
            }
            page += 1
            getFollower(username: username, page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filterdFollowers : followers
        let follower = activeArray[indexPath.item]
        
        let userInfoVC = UserInfoVC()
        userInfoVC.delegate = self
        userInfoVC.username = follower.login
        let navController = UINavigationController(rootViewController: userInfoVC)
        present(navController, animated: true)
    }
    
}

extension FollowerListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty  else {
            filterdFollowers.removeAll()
            isSearching = false
            updateData(on: followers)
            return
        }
        
        isSearching = true
        
        filterdFollowers = followers.filter({ $0.login.lowercased().contains(filter.lowercased())
        })
        
        updateData(on: filterdFollowers)
    }
    
  
    
}

extension FollowerListVC: UserInfoVCDelegate {
    func didRequestFollowers(username: String) {
        self.username = username
        title = username
        page = 1
        isSearching = false
        followers.removeAll()
        filterdFollowers.removeAll()
        
        navigationItem.searchController?.searchBar.text = ""
        navigationItem.searchController?.isActive = false
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        //navigationItem.searchController?.dismiss(animated: false)
        //collectionView.scrollsToTop = true
        
        
        
        getFollower(username: username, page: page)
    }
    
    
}   
