//
//  ViewController.swift
//  Spotify
//
//  Created by Alfan on 24/10/23.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var collectionView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Home"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .done,
            target: self,
            action: #selector(didTapSetting)
        )
        
        handlerGetData()
    }
    
    private func handlerGetData() {
        APICaller.shared.getRecommendationGenre { result in
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                
                APICaller.shared.getRecommendationPlaylist(genres: seeds) { result in
                    
                }
                
            case .failure(let error): break
                
            }
        }
    }
    
    
    @objc func didTapSetting() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

