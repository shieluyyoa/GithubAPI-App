//
//  GFRepoItemVC.swift
//  GithubFollowers
//
//  Created by Oscar Lui on 24/8/2022.
//

import UIKit

protocol GFRepoItemVCDelegate: AnyObject {
    
    func didTapGitHubProfile(for user: User)
  
}

class GFRepotItemVC: GFItemInfoVC {
    
    weak var delegate: GFRepoItemVCDelegate?
    
    init(user: User, delegate: GFRepoItemVCDelegate) {
        super.init(user: user)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
        
    }
    
    private func configureItems() {
        itemInfoViewOne.set(itemInfoType: .repos, with: user.publicRepos)
        itemInfoViewTwo.set(itemInfoType: .gists, with: user.publicGists)
        actionButton.set(color: .systemPurple, title: "GitHub Profile", systemImageName: "person")
    }
    
    
    override func actionButtonTapped() {
        delegate?.didTapGitHubProfile(for: user)
    }
}
