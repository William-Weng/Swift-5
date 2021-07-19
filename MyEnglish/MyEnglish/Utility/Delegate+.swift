/// ~/Library/Developer/Xcode/UserData/CodeSnippets/

import UIKit
import WebKit
import AuthenticationServices
import CoreLocation
import PencilKit
import Photos

// MARK: - UIApplicationDelegate
//@UIApplicationMain
//final class AppDelegate: UIResponder, UIApplicationDelegate {
//
//    var window: UIWindow?
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { return true }
//
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool { return true }                                               // URL Scheme
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool { return true }   // Universal Link
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}                                                               // Push Token
//
//    func applicationDidBecomeActive(_ application: UIApplication) {}
//    func applicationWillResignActive(_ application: UIApplication) {}
//
//    func applicationWillEnterForeground(_ application: UIApplication) {}
//    func applicationDidEnterBackground(_ application: UIApplication) {}
//
//    func applicationWillTerminate(_ application: UIApplication) {}
//
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask { return .all }                                   // 畫面旋轉的方向設定
//
//    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {}
//}
//
//@available(iOS 13.0, *)
//extension AppDelegate {
//
//    /// 修正iOS13之前不支援SceneDelegate的問題
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration { return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role) }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
//}

// MARK: - UIWindowSceneDelegate
//@available(iOS 13.0, *)
//final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) { guard let _ = (scene as? UIWindowScene) else { return } }
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {}
//
//    func sceneDidDisconnect(_ scene: UIScene) {}
//
//    func sceneDidBecomeActive(_ scene: UIScene) {}
//    func sceneWillResignActive(_ scene: UIScene) {}
//
//    func sceneWillEnterForeground(_ scene: UIScene) {}
//    func sceneDidEnterBackground(_ scene: UIScene) {}
//
//    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {}
//}
//
//// MARK: - SplitView
//@available(iOS 13.0, *)
//extension SceneDelegate: UISplitViewControllerDelegate {
//
//    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
//        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
//        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
//        if topAsDetailController.detailItem == nil { return true }
//        return false
//    }
//}
//
//// MARK: - 推播相關 (推播的狀態)
//extension AppDelegate {
//
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let pushToken = deviceToken.reduce("") { return $0 + String(format: "%02x", $1) }
//        pushTokenTest(pushToken)
//    }
//
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {}
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {}
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {}
//}
//
//// MARK: - UNUserNotificationCenterDelegate
//extension AppDelegate: UNUserNotificationCenterDelegate {
//
//    /// optional func userNotificationCenter() => 讓APP在前景也會彈出「推播的視窗」
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.badge, .sound, .alert])
//    }
//}

final class YourViewController: UIViewController {
    
    override var prefersHomeIndicatorAutoHidden: Bool { return false }
    
    override func viewDidLoad() { super.viewDidLoad() }
    override func viewDidLayoutSubviews() {}
    override func viewWillLayoutSubviews() {}

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { view.endEditing(true) }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
}

final class SimpleTransition: NSObject {}

// TODO: - Delegate
// MARK: - UITableViewDataSource, UITableViewDelegate
extension YourViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 0 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { return UITableViewCell() }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {}
}

// MARK: UICollectionViewDataSource
extension YourViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return 0 }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { return UICollectionViewCell() }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView { return UICollectionReusableView() }
}

// MARK: UICollectionViewDelegate
extension YourViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
}

// MARK: - UICollectionViewDragDelegate
extension YourViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] { return [] }
}

// MARK: UIScrollViewDelegate
extension YourViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension YourViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return 0 }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView { return UIView() }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat{ return 44 }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat { return 44 }
}

// MARK: - UIViewControllerTransitioningDelegate
extension YourViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? { return nil }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension YourViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {}
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { dismiss(animated: false, completion: nil) }
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {}
}

// MARK: - PHPhotoLibraryChangeObserver
extension YourViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {}
}

// MARK: - UIGestureRecognizerDelegate
extension YourViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool { return true }
}

// MARK: - UITextFieldDelegate
extension YourViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {}
    func textFieldDidEndEditing(_ textField: UITextField) {}
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { return true }
}

// MARK: - UISearchBarDelegate
extension YourViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {}
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {}
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {}
}

// MARK: - UISearchResultsUpdating
extension YourViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {}
}

// MARK: - CLLocationManagerDelegate
extension YourViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {}
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {}
}

// MARK: - WKNavigationDelegate
extension YourViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {}
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {}
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping ((WKNavigationResponsePolicy) -> Void)){ decisionHandler(.allow) }
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) { authorizationSetting(webView, didReceive: challenge, completionHandler: completionHandler) }
}

// MARK: - WKUIDelegate
extension YourViewController: WKUIDelegate {

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) { completionHandler() }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) { completionHandler(true) }
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) { completionHandler(nil) }
}

// MARK: - WKWebView小工具
extension YourViewController {
    
    /// 需要授權的設定 (需要授權的時候才開，不然會crash)
    private func authorizationSetting(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let authorization = (host: "https://www.google.com/", user: "user", password: "password")

        if challenge.protectionSpace.host == authorization.host {
            let credential = URLCredential(user: authorization.user, password: authorization.password, persistence: URLCredential.Persistence.forSession)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate (SignInWithApple)
@available(iOS 13.0, *)
extension YourViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {}
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) { wwPrint("SignInWithApple Error => \(error)") }
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor { guard let window = view.window else { fatalError() }; return window }
}

// MARK: - URLSessionDownloadDelegate
extension YourViewController: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {}
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {}
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {}
}

// MARK: - URLSessionDataDelegate
extension YourViewController: URLSessionDataDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {}
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {}
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {}
}

// TODO: - Transitioning
// MARK: - UINavigationControllerDelegate => ❶ Navigation
extension SimpleTransition: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? { return nil }
}

// MARK: - UITabBarControllerDelegate => ❷ TabBar
extension SimpleTransition: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? { return SimpleTransition() }
}

// MARK: - UIViewControllerTransitioningDelegate => ❸ Modal
extension SimpleTransition: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? { return SimpleTransition() }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? { return SimpleTransition() }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SimpleTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { return 0.5 }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
}

// TODO: - PencilKit
// MARK: - PKCanvasViewDelegate
@available(iOS 13.0, *)
extension YourViewController: PKCanvasViewDelegate {
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {}
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {}
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {}
}

// MARK: - PKToolPickerObserver
@available(iOS 13.0, *)
extension YourViewController: PKToolPickerObserver {
    
    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {}
    func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {}
    func toolPickerIsRulerActiveDidChange(_ toolPicker: PKToolPicker) {}
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {}
}
