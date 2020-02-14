//
//  DataManager.swift
//  ChicagoLandmarks
//

import Foundation
import MapKit

public class DataManager {
  
    // MARK: - Singleton Stuff
    public static let sharedInstance = DataManager()
  
    //This prevents others from using the default '()' initializer
    fileprivate init() {}

    // Your code (these are just example functions, implement what you need)
    func loadAnnotationFromPlist() -> [Place]{
        let pathBundle = Bundle.main.path(forResource: "Data", ofType: ".plist")
        let root = NSDictionary(contentsOfFile: pathBundle!)
        let places:[NSDictionary] = root?["places"] as! Array<NSDictionary>
        var result:[Place] = []
        for item in places {
            let place = Place()
            place.name = item["name"] as? String
            place.longDescription = item["description"] as? String
            let lat = item["lat"] as! Double
            let long = item["long"] as! Double
            place.coordinate = CLLocationCoordinate2DMake(lat, long)
            result.append(place)
        }
        return result
    }
    
    func loadRegionFromPlist() -> [Any]{
        let pathBundle = Bundle.main.path(forResource: "Data", ofType: ".plist")
        let root = NSDictionary(contentsOfFile: pathBundle!)
        let result:[Any] = root?["region"] as! Array<Any>
        return result
    }
    
    func saveFavorite(favorite:String) {
        let defaults = UserDefaults.standard
        var array = listFavorites()
        array.append(favorite)
        defaults.set(array, forKey: "SavedFavorites")
    }
    
    func deleteFavorite(favorite:String) {
        let defaults = UserDefaults.standard
        var array = listFavorites()
        guard let index = array.firstIndex(of: favorite) else {
            return
        }
        array.remove(at: index)
        defaults.set(array, forKey: "SavedFavorites")
    }
    
    func listFavorites() -> [String]{
        let defaults = UserDefaults.standard
        let array = defaults.object(forKey:"SavedFavorites") as? [String] ?? [String]()
        return array
    }
  
}
