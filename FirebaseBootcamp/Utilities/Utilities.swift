//
//  Utilities.swift
//  FirebaseBootcamp
//
//  Created by Yasin Erdemli on 13.05.2023.
//

import Foundation
import UIKit

final class Utilities {
    
    static let shared = Utilities()
    
    private init() { }
    
    func getTopViewController() throws -> UIViewController {
        var topMostViewController: UIViewController? {
            guard let window = UIApplication
                .shared
                .connectedScenes
                .compactMap({ item in
                    (item as? UIWindowScene)?.keyWindow
                }).last else {
                return nil
            }
            return window.rootViewController
        }
        
        guard let view = topMostViewController else { throw URLError(.cannotConnectToHost) }
        return view
    }
    
}
