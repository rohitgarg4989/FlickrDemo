//
//  UIImageView+Downloader.swift
//  FlickrDemo
//
//  Created by ROHIT GARG on 5/16/17.
//
//

import UIKit

extension UIImageView {
    
    /*
    func download(fromModel model: Photo, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        self.image = nil
        self.image = UIImage(named: "placeholder")!
        URLSession.shared.dataTask(with: model.imageUrl) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            OperationQueue.main.addOperation({
                model.image = image
                self.image = image
            })
            
        }.resume()
    }
    */
    
    
    // MARK: - Image downloader method
    
    func downloadImageFrom(Model model: Photo, completionHandler: @escaping (_ image: UIImage?) -> Void) {

        let urlRequest = URLRequest(url: model.imageUrl)
        
        let session: URLSession = {
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
            return session
        }()
                
        let task: URLSessionDataTask = session.dataTask( with: urlRequest as URLRequest) { (data, response, error) in
            
            guard error == nil else {
                print("Error while downloading \(error!.localizedDescription)")
                return
            }
            
            guard let image =  UIImage(data: data!) else {
                return
            }
            
            completionHandler(image)
            
        }
        
        task.resume()
        
    }
    
    internal func adjustContentMode() {
        
        guard let image = self.image else {
            return
        }
        
        if image.size.width > bounds.size.width || image.size.height > bounds.size.height {
            contentMode = .scaleAspectFit
        } else {
            contentMode = .scaleAspectFit
        }
        
        self.clipsToBounds = true
    }
    
}
