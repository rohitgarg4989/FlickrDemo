//
//  FlickrGridViewController.swift
//  FlickrDemo
//
//  Created by ROHIT GARG on 5/16/17.
//
//

import UIKit
import AVFoundation

private let reuseIdentifier = "Cell"

class FlickrGridViewController: UICollectionViewController {
    
    var photos = [Photo]()
    
    var topSearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topSearchBar.frame = CGRect(x: 0, y: 20, width:self.view.frame.size.width, height: 44)
        topSearchBar.delegate = self
        topSearchBar.showsCancelButton = true
        self.view.addSubview(topSearchBar)
        
        //collectionView!.backgroundColor = UIColor.clear
        collectionView!.contentInset = UIEdgeInsets(top: 20 + 44, left: 5, bottom: 10, right: 5)
        
        if let layout = collectionView?.collectionViewLayout as? FlickrGridLayout {
            layout.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension FlickrGridViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchImagesBy(tag: searchBar.text!)
        self.view.endEditing(true)
    }
}

//MARK: - collection view datasource methods
extension FlickrGridViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrGridCell
        
        cell.tag = indexPath.row
        
        // Configure the cell
        cell.photo = photos[indexPath.item]
        
        if (cell.photo?.hasImage() == true) {
            cell.imageView.image = cell.photo?.image
        }
        else {
            
            cell.imageView.downloadImageFrom(Model: cell.photo!, completionHandler: { (image) in
               
                // Imp. check: if the cell is still visible ...
                if let cell: FlickrGridCell = collectionView.cellForItem(at: indexPath) as? FlickrGridCell {
                    
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                    
                    // store the image in modal
                    cell.photo?.image = image!
                    self.photos[indexPath.item] = cell.photo!
                }
                
            })
            
        }
        
        //cell.buttonFavourite //addTarget
        
        return cell
    }
    
}

extension FlickrGridViewController : FlickrGridLayoutDelegate {
    // 1. Returns the photo height
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath , withWidth width:CGFloat) -> CGFloat {
        let photo = photos[indexPath.item]
        let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        
        let rect = AVMakeRect(aspectRatio: photo.image.size, insideRect: boundingRect)
        return rect.size.height
    }
    
    // 2. Returns the annotation size based on the text
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        let annotationPadding = CGFloat(4)
        let annotationHeaderHeight = CGFloat(17)
        
        let photo = photos[indexPath.item]
        let font = UIFont(name: "AvenirNext-Regular", size: 10)!
        let commentHeight = photo.heightFortitle(font: font, width: width)
        let height = annotationPadding + annotationHeaderHeight + commentHeight + annotationPadding
        return height
    }
}


//MARK: - flicker API call

extension FlickrGridViewController {
    
    func searchImagesBy(tag: String) {
        
        let urlComponents = NSURLComponents()
        urlComponents.scheme = networkrequest_scheme;
        urlComponents.host = networkrequest_host;
        urlComponents.path = networkrequest_path;
        
        // add params
        let perPageQuery = NSURLQueryItem(name: "per_page", value: "50")
        let formatQuery = NSURLQueryItem(name: "format", value: "json")
        let apiKeyQuery = NSURLQueryItem(name: "api_key", value: API_KEY)
        let methodQuery = NSURLQueryItem(name: "method", value: API_SEARCH_PHOTO_BY_TAG)
        let tagsQuery = NSURLQueryItem(name: "tags", value: tag)
        let nojsoncallback = NSURLQueryItem(name: "nojsoncallback", value: "1")
        
        urlComponents.queryItems = [perPageQuery as URLQueryItem , formatQuery as URLQueryItem, apiKeyQuery as URLQueryItem, methodQuery as URLQueryItem, tagsQuery as URLQueryItem, nojsoncallback as URLQueryItem]
        
        //    print(urlComponents.url)
        
        let urlRequest = NSURLRequest(url: urlComponents.url!)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            if let jsonData = data, let responseDict = try? JSONSerialization.jsonObject(with: jsonData, options:.mutableLeaves) as? [String: AnyObject] {
                print(responseDict ?? "Invalid Json")
              
              if let dictPhotos = responseDict?["photos"] as? NSDictionary{
                if let itemArray = dictPhotos.object(forKey: "photo") as? NSArray{
                    
                    DispatchQueue.main.async {
                        self.photos = Photo.allPhotos(array: itemArray)
                        self.collectionView?.reloadData()
                    }
                }
              }
                // Fill this response into Data Model and update Collection view content/Datasource accordingly
            }
        })
        
        task.resume()
    }
  
}


