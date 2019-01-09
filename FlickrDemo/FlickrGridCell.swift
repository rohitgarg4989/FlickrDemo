//
//  FlickrGridCell.swift
//  FlickrDemo
//
//  Created by ROHIT GARG on 5/16/17.
//
//

import UIKit

class FlickrGridCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var  buttonFavourite: UIButton!
    @IBOutlet weak var imageViewHeightLayoutConstraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photo = nil;
        self.captionLabel.text = ""
        self.imageView.image = UIImage(named: "placeholder")!
    }
    
    var photo: Photo? {
        didSet {
            if let photo = photo {
                self.captionLabel.text = photo.title
            }
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? FlickrGridLayoutAttributes {
            imageViewHeightLayoutConstraint.constant = attributes.photoHeight
        }
    }
}
