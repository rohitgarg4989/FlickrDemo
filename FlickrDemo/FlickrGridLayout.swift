//
//  FlickrGridLayout.swift
//  FlickrDemo
//
//  Created by ROHIT GARG on 5/16/17.
//
//

import UIKit

protocol FlickrGridLayoutDelegate {
  // 1. Method to ask the delegate for the height of the image
  func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath , withWidth:CGFloat) -> CGFloat
  // 2. Method to ask the delegate for the height of the annotation text
  func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
  
}

class FlickrGridLayoutAttributes:UICollectionViewLayoutAttributes {
  
  // 1. Custom attribute
  var photoHeight: CGFloat = 0.0
  
  // 2. Override copyWithZone to conform to NSCopying protocol
  
  override func copy(with zone: NSZone? = nil) -> Any {
    let copy = super.copy(with: zone) as! FlickrGridLayoutAttributes
    copy.photoHeight = photoHeight
    return copy
  }
  
  // 3. Override isEqual
  override func isEqual(_ object: Any?) -> Bool {
    if let attributtes = object as? FlickrGridLayoutAttributes {
      if( attributtes.photoHeight == photoHeight  ) {
        return super.isEqual(object)
      }
    }
    return false
  }
  
}

class FlickrGridLayout: UICollectionViewLayout {
  
  //1. FlickrGrid Layout Delegate
  var delegate:FlickrGridLayoutDelegate!

  //2. Configurable properties
  var numberOfColumns = 2
  var cellPadding: CGFloat = 6.0
  
  //3. Array to keep a cache of attributes.
  private var cache = [FlickrGridLayoutAttributes]()
  
  //4. Content height and size
  private var contentHeight:CGFloat  = 0.0
  private var contentWidth: CGFloat {
    let insets = collectionView!.contentInset
    return collectionView!.bounds.width - (insets.left + insets.right)
  }
  
  override class var layoutAttributesClass: AnyClass {
    return FlickrGridLayoutAttributes.self
  }
  
  override func prepare() {
    // 1. Only calculate once
    if cache.isEmpty {
      
      // 2. Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
      let columnWidth = contentWidth / CGFloat(numberOfColumns)
      var xOffset = [CGFloat]()
      for column in 0 ..< numberOfColumns {
        xOffset.append(CGFloat(column) * columnWidth )
      }
      var column = 0
      var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
      
      // 3. Iterates through the list of items in the first section
      for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
        
        let indexPath = IndexPath(row: item, section: 0)
        // 4. Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
        
        let width = columnWidth - cellPadding*2
        
        let photoHeight = delegate.collectionView(collectionView: collectionView!, heightForPhotoAtIndexPath: indexPath as NSIndexPath, withWidth: width)

        let annotationHeight = delegate.collectionView(collectionView: collectionView!, heightForAnnotationAtIndexPath: indexPath as NSIndexPath, withWidth: width)

        let height = cellPadding +  photoHeight + annotationHeight + cellPadding

        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)

        let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
        
        // 5. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
        let attributes = FlickrGridLayoutAttributes(forCellWith: indexPath)
        attributes.photoHeight = photoHeight
        attributes.frame = insetFrame
        cache.append(attributes)
        
        // 6. Updates the collection view content height
        contentHeight = max(contentHeight, frame.maxY)
        yOffset[column] = yOffset[column] + height
        column = column >= (numberOfColumns - 1) ? 0 : column+1
        
      }
    }
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    // Loop through the cache and look for items in the rect
    for attributes  in cache {
      if attributes.frame.intersects(rect) {
        layoutAttributes.append(attributes)
      }
    }
    return layoutAttributes
  }
  
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }

}
