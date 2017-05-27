//
//  FeedController.swift
//  FacebookClone
//
//  Created by Vamshi Krishna on 23/05/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import UIKit
private let reuseIdentifier = "Cell"

class Post:SafeJsonObject{
    var name:String?
    var statusText :String?
    var profileImageName:String?
    var statusImageName: String?
    var numLikes: NSNumber?
    var numComments: NSNumber?
    
    var location:Location?
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "location" {
            location = Location()
            location?.setValuesForKeys(value as! [String:AnyObject])
        }
        else{
            super.setValue(value, forKey: key)
        }
    
    }
}

class Location:NSObject{
    var city:String?
    var state:String?
}
class SafeJsonObject:NSObject{
    override func setValue(_ value: Any?, forKey key: String) {
        let selectorString = "set\(key.uppercased().characters.first!)\(String(key.characters.dropFirst())):"
        let selector = Selector(selectorString)
        if responds(to: selector) {
            super.setValue(value, forKey: key)
        }
    }
}


class FeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "all_posts", ofType: "json") {
            do {
                let data = try(Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe))
                let jsonDictionary = try(JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? [String: Any]
                if let postsArray = jsonDictionary?["posts"] as? [[String: AnyObject]] {
                    self.posts = [Post]()
                    for postDictionary in postsArray {
                        let post = Post()
                        post.setValuesForKeys(postDictionary)
                        self.posts.append(post)
                    }
                }
            } catch let err {
                print(err)
            }
            
        }
        
        navigationItem.title = "Facebook Feed"
        self.collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        self.collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.alwaysBounceVertical = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        feedCell.post = posts[indexPath.item]
        feedCell.feedController = self
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let statusText = posts[indexPath.item].statusText{
            let rect = NSString(string: statusText).boundingRect(with: Utility.shared.CGSizeMake(view.frame.width, 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14)], context: nil)
            return Utility.shared.CGSizeMake(view.frame.width, rect.height+344+24)
        }
        return Utility.shared.CGSizeMake(view.frame.width, 500)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    let blackBackgroundView = UIView()
    var statusImageView : UIImageView?
    let zoomImageView = UIImageView()
    let navBarCoverView = UIView()
    let tabBarCoverView = UIView()
    
    func animateImageView(statusImageView:UIImageView){
        self.statusImageView = statusImageView
        if let startingFrame = statusImageView.superview?.convert(statusImageView.frame, to: nil){
            statusImageView.alpha = 0;
            
            blackBackgroundView.frame = self.view.frame
            blackBackgroundView.backgroundColor = UIColor.black
            blackBackgroundView.alpha = 0
            view.addSubview(blackBackgroundView)
            
            navBarCoverView.frame = Utility.shared.CGRectMake(0, 0, self.view.frame.width, 64)
            navBarCoverView.backgroundColor = .black
            navBarCoverView.alpha = 0
            
            if let keyWindow = UIApplication.shared.keyWindow{
                keyWindow.addSubview(navBarCoverView)
                tabBarCoverView.frame = Utility.shared.CGRectMake(0, keyWindow.frame.height-49, self.view.frame.width, 49)
                tabBarCoverView.backgroundColor = .black
                tabBarCoverView.alpha = 0
                keyWindow.addSubview(tabBarCoverView)
            }
            
            zoomImageView.backgroundColor = UIColor.red
            zoomImageView.frame = startingFrame
            zoomImageView.isUserInteractionEnabled = true
            zoomImageView.image = statusImageView.image
            zoomImageView.contentMode = .scaleAspectFill
            zoomImageView.clipsToBounds = true
            view.addSubview(zoomImageView)
            
            zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { () -> Void in
                
                let height = (self.view.frame.width/startingFrame.width) * startingFrame.height
                let y = self.view.frame.height/2 - height/2
                self.zoomImageView.frame = Utility.shared.CGRectMake(0, y, self.view.frame.width, height)
                self.blackBackgroundView.alpha = 1
                self.navBarCoverView.alpha = 1
                self.tabBarCoverView.alpha = 1
                
            }, completion: nil)
            
        }
    }
    
    func zoomOut(){
         if let startingFrame = statusImageView?.superview?.convert((statusImageView?.frame)!, to: nil){
            UIView.animate(withDuration: 0.75, animations: { () -> Void in
                self.zoomImageView.frame = startingFrame
                self.blackBackgroundView.alpha = 0
                self.navBarCoverView.alpha = 0
                self.tabBarCoverView.alpha = 0
            }, completion: { (didComplete) -> Void in
                self.zoomImageView.removeFromSuperview()
                self.blackBackgroundView.removeFromSuperview()
                self.navBarCoverView.removeFromSuperview()
                self.statusImageView?.alpha = 1
                self.tabBarCoverView.removeFromSuperview()
            })
        }
    }
}

class FeedCell:UICollectionViewCell{
    
    var feedController:FeedController?
    func animate(){
        feedController?.animateImageView(statusImageView: statusImageView)
    }
    
    var post:Post?{
        didSet{
            if let name = post?.name {
                
                let attributedText = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
                
                if let city = post?.location?.city, let state = post?.location?.state {
                    attributedText.append(NSAttributedString(string: "\n\(city), \(state)  •  ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName:
                        UIColor.returnRGBColor(r: 155, g: 161, b: 161, alpha: 1)]))
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 4
                    attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.string.characters.count))
                    let attachment = NSTextAttachment()
                    attachment.image = UIImage(named: "globe_small")
                    attachment.bounds = CGRect(x: 0, y: -2, width: 12, height: 12)
                    attributedText.append(NSAttributedString(attachment: attachment))
                }
                
                nameLabel.attributedText = attributedText
                
            }
            
            if let statusText = post?.statusText{
                statusTextView.text = statusText
            }
            
            if let profileImageName = post?.profileImageName{
                profileImageView.image = UIImage(named: profileImageName)
            }
            
            if let statusImageName = post?.statusImageName{
                statusImageView.image = UIImage(named: statusImageName)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    let statusImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "zuckdog")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let statusTextView : UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "zuckprofile")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let likesCommentsLabel: UILabel = {
        let label = UILabel()
        label.text = "10000 Likes 2000 Comments"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.returnRGBColor(r: 155, g: 161, b: 171, alpha: 1)
        return label
    }()
    
    let dividerLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.returnRGBColor(r: 226, g: 228, b: 232, alpha: 1)
        return view
    }()
    
    static func buttonForTitleAndImage(title:String, imageName:String) -> UIButton{
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.returnRGBColor(r: 142, g: 148, b: 161, alpha: 1), for: .normal)
        button.setImage(UIImage(named:imageName), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }
    
    let likeButton = FeedCell.buttonForTitleAndImage(title: "Like", imageName: "like")
    let commentButton = FeedCell.buttonForTitleAndImage(title: "Comment", imageName: "comment")
    let shareButton = FeedCell.buttonForTitleAndImage(title: "Share", imageName: "share")
    
    func setupViews(){
        backgroundColor = UIColor.white
        
        addSubview(nameLabel)
        addSubview(profileImageView)
        addSubview(statusTextView)
        addSubview(statusImageView)
        addSubview(likesCommentsLabel)
        addSubview(dividerLineView)
        addSubview(likeButton)
        addSubview(commentButton)
        addSubview(shareButton)
        
        statusImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animate)))
        
       addConstraintsWithFormat(format: "H:|-8-[v0(44)]-8-[v1]|", views: profileImageView, nameLabel)
       addConstraintsWithFormat(format: "H:|-4-[v0]-4-|", views: statusTextView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: statusImageView)
        addConstraintsWithFormat(format: "H:|-12-[v0]|", views: likesCommentsLabel)
        addConstraintsWithFormat(format: "H:|-12-[v0]-12-|", views: dividerLineView)
        addConstraintsWithFormat(format: "H:|[v0(v2)][v1(v2)][v2]|", views: likeButton, commentButton ,shareButton)
       addConstraintsWithFormat(format: "V:|-12-[v0]", views: nameLabel)
       addConstraintsWithFormat(format: "V:|-8-[v0(44)]-4-[v1]-4-[v2(200)]-8-[v3(24)]-8-[v4(0.4)][v5(44)]|", views: profileImageView, statusTextView, statusImageView, likesCommentsLabel, dividerLineView, likeButton)
        addConstraintsWithFormat(format: "V:[v0(44)]|", views: commentButton)
        addConstraintsWithFormat(format: "V:[v0(44)]|", views: shareButton)
     
    }
}
