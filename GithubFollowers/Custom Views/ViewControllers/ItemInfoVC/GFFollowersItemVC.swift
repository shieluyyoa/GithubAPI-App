//
//  GFFollowersVC.swift
//  GithubFollowers
//
//  Created by Oscar Lui on 24/8/2022.
//

import UIKit

protocol GFFollowersItemVCDelegate: AnyObject {
    
    func didTapGetFollowers(for user: User)
}

class GFFollowersItemVC: GFItemInfoVC {
    
    weak var delegate: GFFollowersItemVCDelegate?
    
    init(user: User, delegate: GFFollowersItemVCDelegate) {
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
        itemInfoViewOne.set(itemInfoType: .repos, with: user.followers)
        itemInfoViewTwo.set(itemInfoType: .gists, with: user.following)
        actionButton.set(color: .systemGreen, title: "Get Followers", systemImageName: "person.3")
    }
    
    override func actionButtonTapped() {
        delegate?.didTapGetFollowers(for: user)
    }
    

}
