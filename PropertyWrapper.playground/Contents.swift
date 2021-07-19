/// [阿斌的筆記: [iOS] PropertyWrapper屬性包裝器](http://aiur3908.blogspot.com/2019/08/ios-propertywrapper.html)
import UIKit

struct UserData {
    @UserDefault("name") static var name: String?
    @UserDefault("age") static var age: Int?
}

@propertyWrapper
struct UserDefault<T> {

    var wrappedValue: T? {
        get { return UserDefaults.standard.object(forKey: key) as? T }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
    
    let key: String

    init(_ key: String) {
        self.key = key
    }
}

print(UserData.name ?? "nil")
print(UserData.age ?? "nil")

UserData.name = nil
UserData.age = nil

print(UserData.name ?? "nil")
print(UserData.age ?? "nil")
