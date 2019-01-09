import UIKit

//Need to change this model as per flickr api response

class Photo {
    
    class func allPhotos(array: NSArray) -> [Photo] {
        var photos = [Photo]()
        for dictionary in array {
            let photo = Photo(dictionary: dictionary as! NSDictionary)
            photos.append(photo)
        }
        return photos
    }
    
    var photoId: String
    var title: String
    var imageUrl: URL
    var farmId: String
    var serverId: String
    var secret: String
    var image: UIImage
    
    
    init(photoId: String, title: String, farmId: String, serverId: String, secret: String,imageUrl: URL) {
        self.photoId = photoId
        self.title = title
        self.farmId = farmId
        self.serverId = serverId
        self.secret = secret
        self.imageUrl = imageUrl
        self.image = UIImage(named: "placeholder")! //placeholder need to be set
    }
    
    convenience init(dictionary: NSDictionary) {
        let photoId = dictionary["id"] as? String
        let title = dictionary["title"] as? String
        let farm = dictionary["farm"] as? Int
        let server = dictionary["server"] as? String
        let secret = dictionary["secret"] as? String
        let stringUrl = String("http://farm\(farm!).staticflickr.com/\(server!)/\(photoId!)_\(secret!).jpg")
        let url: URL = URL.init(string: stringUrl!)!
        self.init(photoId: photoId!, title: title!, farmId: String(describing: farm), serverId: server!, secret: secret!, imageUrl: url)
    }
    
    func heightFortitle(font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: title).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.height)
    }

    func hasImage() -> Bool {
        // check if image is already downlaoded 
        return self.image == UIImage(named: "placeholder")! ? false : true
    }

}
