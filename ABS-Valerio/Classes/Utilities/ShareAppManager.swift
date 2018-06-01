import Foundation
import UIKit

class ShareAppManager: NSObject {
    
    static let shared = ShareAppManager()
    
    func shareApp(appId: String, controller: UIViewController, cell: UITableViewCell) {
        
        let appUrl = "https://itunes.apple.com/app/id\(appId)"
        
        if let infoDict = Bundle.main.infoDictionary as NSDictionary?,
            let imagesArray = infoDict.value(forKeyPath: "CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles") as? [Any],
            let imageName = imagesArray.last as? String,
            let appIcon = UIImage(named: imageName) {
            
            let shareItems = ["trayThisAppKey".localized, appIcon, appUrl] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            
            if #available(iOS 8.0, *) {
                activityViewController.popoverPresentationController?.sourceView = controller.view
                activityViewController.popoverPresentationController?.sourceRect = cell.frame
            }
            
            controller.present(activityViewController, animated: true, completion: nil)
        }
    }
}
