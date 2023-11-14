//
//  ViewController.swift
//  Spotify
//
//  Created by Alfan on 24/10/23.
//

import UIKit

enum BrowseSectionType {
    case NewReleases(viewModels: [NewReleasesCellViewModel])
    case FeaturedPlaylist(viewModels: [NewReleasesCellViewModel])
    case RecommendedTracks(viewModels: [NewReleasesCellViewModel])
}

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return HomeViewController.createSectionLayout(section: sectionIndex)
    })
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()
    
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
        
        view.addSubview(spinner)
        
        configureCollectionView()
        handlerGetData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame =  view.bounds
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
    }
    
    private func handlerGetData() {
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        group.enter()
        
        var newRelases: NewReleasesModel?
        var featuredPlaylist: FeaturedPlaylistsModel?
        var recommendedTracks: RecommendationModel?
        
        
        // New Releases
        APICaller.shared.getNewReleases { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                newRelases = model
            case .failure(let error):
                print("Err NewRelease: \(error.localizedDescription)")
            }
        }
        
        // Featured Playlist
        
        APICaller.shared.getFeaturedPlaylist { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                featuredPlaylist = model
            case .failure(let error):
                print("Err FeaturedPlaylist: \(error.localizedDescription)")
            }
        }
        
        // Recommended tracks
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
                
                APICaller.shared.getRecommendationPlaylist(genres: seeds) { resultRecommended in
                    defer {
                        group.leave()
                    }
                    
                    switch resultRecommended {
                    case .success(let model):
                        recommendedTracks = model
                    case .failure(let error):
                        print("Err RecomendedTracks: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                print("Err RecomendedGenre: \(error.localizedDescription)")
            }
        }
        
        group.notify(queue: .main) {
            guard let newsAlbums = newRelases?.albums.items,
                  let playlist = featuredPlaylist?.playlists.items,
                  let tracks = recommendedTracks?.tracks else {
                return
            }
            
            self.configureModels(newAlbums: newsAlbums, playlist: playlist, tracks: tracks )
        }
    }
    
    private func configureModels(newAlbums: [Album], playlist: [Playlist], tracks: [AudioTrackModel]) {
        sections.append(.NewReleases(viewModels:  newAlbums.compactMap({
            return NewReleasesCellViewModel(
                name: $0.name,
                artworkUrl: URL(string: $0.images.first?.url ?? ""),
                numberOfTracks: $0.total_tracks,
                artisName: $0.artists.first?.name ?? "-"
            )
        })))
        sections.append(.FeaturedPlaylist(viewModels:  []))
        sections.append(.RecommendedTracks(viewModels: []))
        collectionView.reloadData()
    }
    
    
    @objc func didTapSetting() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .NewReleases(let viewModels):
            return viewModels.count
        case .FeaturedPlaylist(let viewModels):
            return viewModels.count
        case .RecommendedTracks(let viewModels):
            return viewModels.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        
        print("isi type \(type)")
        
        switch type {
        case .NewReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier, for: indexPath) as? NewReleaseCollectionViewCell else {
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.row]
            cell.configureModel(with: viewModel)
            return cell
        case .FeaturedPlaylist(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.backgroundColor = .red
            return cell
        case .RecommendedTracks(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.backgroundColor = .yellow
            return cell
        }
    }
    
    private static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0:
            // item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
            
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(360)), subitem: item, count: 3)
            
            // group
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(360)), subitem: verticalGroup, count: 1)
            
            // section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        case 1:
            // item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(150)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
            
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(300)), subitem: item, count: 2)
            
            // group
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(300)), subitem: verticalGroup, count: 1)
            
            // section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        case 2:
            // item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
            
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150)), subitem: item, count: 3)
            
            // group
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85), heightDimension: .absolute(150)), subitem: verticalGroup, count: 1)
            
            // section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
            
        default:
            // item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(360)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
            
            // group
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85), heightDimension: .absolute(360)), subitem: item, count: 1)
            
            // section
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
}
