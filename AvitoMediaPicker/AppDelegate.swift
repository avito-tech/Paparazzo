//
//  AppDelegate.swift
//  AvitoMediaPicker
//
//  Created by Andrey Yutkin on 05.06.16.
//  Copyright © 2016 Avito. All rights reserved.
//

import UIKit
import Marshroute

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PhotoPickerModuleOutput {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window?.rootViewController = MarshrouteFacade().navigationController(NavigationController()) { routerSeed in
            
            let assemblyFactory = AssemblyFactory()
            let photoPickerAssembly = assemblyFactory.photoPickerAssembly()
            
            return photoPickerAssembly.viewController(moduleOutput: self, routerSeed: routerSeed)
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: - PhotoPickerModuleOutput

    func photoPickerDidAddItem(item: PhotoPickerItem) {
    }

    func photoPickerDidUpdateItem(item: PhotoPickerItem) {
    }

    func photoPickerDidRemoveItem(item: PhotoPickerItem) {
    }

    func photoPickerDidFinish() {
    }

    func photoPickerDidCancel() {
    }
}

