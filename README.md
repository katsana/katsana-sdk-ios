# Notes
 
[KatsanaSDK v3](https://github.com/katsana/katsana-sdk-ios/tree/v3) is in development. v3 has been rewritten with better architecture and without using any 3rd party dependencies.

# KatsanaSDK
KatsanaSDK is a framework for accessing data from Katsana platform using iOS/macOS app.

## Installation

KatsanaSDK is available via Cocoapods.

###[Cocoapods](https://cocoapods.org/)

Add these to your Podfile

For iOS
```
use_frameworks!
target "PROJECT_NAME" do
    platform :ios, '8.0'
    pod 'KatsanaSDK', '~>0.9.0'
end
```

For macOS
```
use_frameworks!
target "PROJECT_NAME" do
    platform :osx, 10.11'
    pod 'KatsanaSDK', '~>0.9.0'
end
```

## Usage

Import KatsanaSDK for each source file:
```
import KatsanaSDK
```

In your AppDelegate in the
```
application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil)
```

Configure KatsanaAPI and using client id, client secret and grant type
```
KatsanaAPI.configure(clientId: CLIENT_ID, clientSecret: CLIENT_SECRET, grantType: GRANT_TYPE)
```

Then, you can login using your credential

```
KatsanaAPI.shared.login(email: EMAIL, password: PASSWORD, completion: { user in
    //Handle user login success
}) { error in
    //Login error        
}
```

## Vehicles

```Vehicle``` class contains vehicle information such as vehicle id, today max speed, image url, and current vehicle location.

To load all vehicles information, use:
```
KatsanaAPI.shared.requestAllVehicles(completion: { (vehicles) in
    //Vehicles loaded 
})
```

To load a single vehicle:
```
KatsanaAPI.shared.requestVehicle(vehicleId: "78", completion: { (vehicle) in
    //Vehicle loaded
})
```

You can also use:
```
KatsanaAPI.shared.vehicleWith(vehicleId: "78")
```
which will return vehicle with vehicle id if already requested from server.

## KTVehicle Location

```VehicleLocation``` class contains location data of the vehicle including, coordinate, speed and device voltage.

You can get vehicle location from ```Vehicle``` class 
```
 let location = vehicle.current
```

Or request latest vehicle location:
```
KatsanaAPI.shared.requestVehicleLocation(vehicleId: "78", completion: { (vehicleLocation) in
    //Success
})
```

## Travel

```Travel``` class contains travel history for specific vehicle. Each travel contains trip data for a single day only except for multiple days trip. 

To request travel data for specific day:
```
KatsanaAPI.shared.requestTravel(for: Date(), vehicleId: "78", completion: { (travel) in
    //Success
}) { (error) in
    //Error
}
```

If you need travel data for multiple dates in range:
```
KatsanaAPI.shared.requestTravelSummaries(vehicleId: "78", fromDate: date1, toDate: date2, completion: { (travels) in
    //Success
})
```
Travel summary request also return instance of ```Travel``` but it does not include trip data to save bandwidth.

You can request full travel data for specific date again if needed 
```
let summary = ... //Travel summary already requested from server
KatsanaAPI.shared.requestTravelUsing(summary: summary, completion: { (travel) in
    //Success
}) { (error) in
    //Error
}
```

Requesting a single travel summary for today:
```
KatsanaAPI.shared.requestTravelSummaryToday(vehicleId: "78") { travel in
    //Success   
}
```
