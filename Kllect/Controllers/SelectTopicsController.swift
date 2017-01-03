//
//  SelectTopicsController.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-06.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit
import SVProgressHUD

class SelectTopicsController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionWrapper: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var birthdate:Date?
    
    var mask = CAGradientLayer()
    
    var topics = [Topic]()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.title = ""
        
        setupCollectionView()
        loadTopics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setHidesBackButton(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mask.bounds = collectionWrapper.bounds
    }
    
    func loadTopics() {
        KllectAPI.shared.getTopics { (topics:[Topic]?) in
            self.topics = topics ?? []
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Collection View
    
    func setupCollectionView() {
        collectionView.register(UINib(nibName: "TopicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TopicCollectionViewCell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 20, right: 0)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupCollectionViewMask()
    }
    
    func setupCollectionViewMask() {
        mask.anchorPoint = CGPoint.zero
        mask.bounds = self.collectionWrapper.bounds
        mask.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        mask.locations = [0, 0.05, 0.95, 1]
        self.collectionWrapper.layer.mask = mask
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopicCollectionViewCell", for: indexPath) as! TopicCollectionViewCell
        let topic = topics[indexPath.row]
        cell.setTopic(topic: topic)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let topic = topics[indexPath.row]
        let text = topic.displayName
        let attr = [NSFontAttributeName:TopicCollectionViewCell.font]
        let size = (text as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height:CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attr, context: nil)
        let width = size.width + 66
        let height = CGFloat(50)
        return CGSize(width: round(width), height: round(height))
    }
    
    @IBAction func `continue`(_ sender: UIButton) {
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else {
            SVProgressHUD.showError(withStatus: "Please select at least one interest")
            return
        }
        
        let topics = selectedIndexPaths.map({ self.topics[$0.row] })
        KllectAPI.shared.recordUserTopics(topics: topics, birthdate:self.birthdate) { success, error in
            if success {
                self.openFeed()
            }
            else {
                SVProgressHUD.showError(withStatus: error?.localizedDescription ?? "An unknown error occured. Please try again later")
            }
        }
    }
    
    func openFeed() {
        let feedController = storyboard!.instantiateViewController(withIdentifier: "FeedController") as! FeedController
        self.present(feedController, animated: true, completion: nil)
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    
}














