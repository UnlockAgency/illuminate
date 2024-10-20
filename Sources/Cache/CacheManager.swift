//
//  CacheManager.swift
//  
//
//  Created by Thomas Roovers on 03/10/2022.
//

#if canImport(UIKit)
import UIKit
#endif

public class CacheManager {
    
    nonisolated(unsafe) public static let instance = CacheManager()
    
    private let memoryCache = NSCache<AnyObject, AnyObject>()
    
    public init() {
        
    }
}

extension CacheManager {
    /// Check if has data on mem
    public func cached(key: String) -> Bool {
        return (memoryCache.object(forKey: key as AnyObject) != nil)
    }
    
    /// Clean all mem cache and disk cache. This is an async operation.
    public func clean() {
        memoryCache.removeAllObjects()
    }
    
    /// Clean cache by key. This is an async operation.
    public func clean(byKey key: String) {
        memoryCache.removeObject(forKey: key as AnyObject)
    }
}

extension CacheManager {
    
    // MARK: - Read & write Data
    // ------------------------------

    /// Write data for key. This is an async operation.
    public func write(data: Data, forKey key: String) {
        memoryCache.setObject(data as AnyObject, forKey: key as AnyObject)
    }
    
    /// Read data for key
    public func readData(forKey key:String) -> Data? {
        return memoryCache.object(forKey: key as AnyObject) as? Data
    }
    
    // MARK: - Read & write Codable types
    // ------------------------------

    public func write<T: Encodable>(codable: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(codable)
        write(data: data, forKey: key)
    }
    
    public func readCodable<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = readData(forKey: key) else {
            return nil
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
#if canImport(UIKit)
    // MARK: - Read & write UIImage
    // ------------------------------
    
    public func write(image: UIImage, forKey key: String, format: ImageType? = nil) {
        var data: Data? = nil
        
        if let format = format, format == .png {
            data = image.pngData()
        } else {
            data = image.jpegData(compressionQuality: 0.9)
        }
        
        if let data = data {
            write(data: data, forKey: key)
        }
    }
    
    /// Read image for key. Please use this method to write an image instead of `readObject(forKey:)`
    public func readImage(forKey key: String) -> UIImage? {
        if let data = readData(forKey: key) {
            return UIImage(data: data, scale: 1.0)
        }
        
        return nil
    }
#endif
    
    // MARK: - Read & write String
    // ------------------------------
    
    /// Write a string for key
    public func write(string: String, forKey key: String) throws {
        try write(object: NSString(string: string), forKey: key)
    }
    
    /// Read a string for key
    public func readString(forKey key: String) -> String? {
        return readObject(ofType: NSString.self, forKey: key) as? String
    }
    
    // MARK: - Read & write NSCoding
    // ------------------------------

    public func write<T: NSCoding>(object: T, forKey key: String) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)
        write(data: data, forKey: key)
    }
    
    public func readObject<T: NSCoding & NSObject>(ofType type: T.Type, forKey key: String) -> T? {
        let data = readData(forKey: key)
        
        if let data = data, let object = try? NSKeyedUnarchiver.unarchivedObject(ofClass: type, from: data) {
            return object
        }
        
        return nil
    }
}

extension CacheManager {
    public enum ImageType {
        case unknown
        case png
        case jpeg
    }
}
