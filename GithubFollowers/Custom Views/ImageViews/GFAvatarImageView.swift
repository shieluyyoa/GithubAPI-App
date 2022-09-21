//
//  GFAvatarImageView.swift
//  GithubFollowers
//
//  Created by Oscar Lui on 4/8/2022.
//

import UIKit

class GFAvatarImageView: UIImageView {

    let placeholderImage = Images.placeholder
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func downloadImage(from URL: String) {
        NetworkManager.shared.downloadImage(from: URL) { [weak self] image in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.image = image
            }
        }
    }
       

}
