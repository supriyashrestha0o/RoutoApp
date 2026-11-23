# Routo Flutter frontend

This frontend-only source package implements the Routo design reference with Flutter controls and artwork cropped from the supplied screenshots. The sign-in, OTP, password reset and driver-document screens are local previews. The uploaded reference archive targeted Dart 3.13.3 and Flutter 3.47 or later and contained only Dart source, assets and dependency files. This package uses the same Flutter baseline and retains geolocator and image_picker for the device preview. It has no Django API dependency.

## Run on your Android emulator or phone

The archive contains the app source and artwork. Add it to a fresh Flutter platform shell. From the directory containing this extracted folder, run the following on your Mac.

```sh
flutter create --project-name routo --platforms android,ios routo_mobile
cp routo_rebuilt/pubspec.yaml routo_mobile/
cp -R routo_rebuilt/lib/. routo_mobile/lib/
cp -R routo_rebuilt/assets routo_mobile/
cd routo_mobile
```

Before launching on Android, put these lines inside the root `<manifest>` element in `android/app/src/main/AndroidManifest.xml`, above `<application>`. The preview only needs foreground location.

```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

For iOS, add `NSLocationWhenInUseUsageDescription` and `NSPhotoLibraryUsageDescription` in `ios/Runner/Info.plist` with user-facing explanations. Use the package identifiers agreed with your teammate when setting up the actual Firebase app.

```sh
flutter pub get
flutter run
```

## Try the frontend

- Follow the onboarding cards to the welcome screen. Tap **Get Started** for the registration preview or **Login** for the sign-in preview. Use a sample college address such as demo@patancollege.edu.np, a sample password, and OTP 123456. No real account, email or identity document is needed. **Explore frontend preview** jumps directly to profile setup.
- Create a sample profile, set a future departure, and select **Find a Ride** or **Offer a Ride**.
- As a passenger, open **Matches → Add Example Match → Join Match**. Choose free travel or enter a custom NPR amount. The request appears as pending in Upcoming history. You can also post your own free ride request.
- As a driver, add an example free passenger request under **Matches**, or post your own ride from **Home**. Open the posted ride under **Your Posts** and use **Add Example Request** to exercise the incoming request controls and seat limits.
- Use an accepted trip to exercise chat and the completed-trip review flow. Try report confirmation and blocking from a trip's details. Preview profiles, trips, fare choices, messages, reviews and blocks are session data.
- To run the pure Dart checks from the extracted source, use `dart test/ride_model_check.dart`.

## What is in the source

| File | Contents |
| --- | --- |
| `lib/main.dart` | App entry, splash, onboarding and welcome |
| `lib/design.dart` | Theme, scrolling screen layout, heading, panel, action and field |
| `lib/account.dart` | Login, mock Google chooser, email and OTP preview, password reset and profile editor |
| `lib/journeys.dart` | GPS and manual journey setup, role and vehicle selection, document verification entry and setup confirmation |
| `lib/dashboard.dart` | Navigation, matches, trips, fare, notifications, history, chat, review and safety screens |
| `lib/ride_model.dart` | Preview trip data, matching and seat logic |

The preview matches by destination, calendar date, future departure and a one-hour time window. It accepts pickups within 2 km when both have coordinates, and uses normalized pickup names when coordinates are unavailable. This is a pickup-and-destination approximation of route similarity. The gender preference is captured in setup and still needs to be applied to backend data. The four-student cap is interpreted as one driver and up to three passengers.

## Firebase handoff

Authentication and driver document submission use local sample data. Live user verification, push notifications, requests across devices and shared chat are deferred until Firebase integration. The maps in onboarding are illustrations. Trip details in the preview remain text-based.

Before using live accounts, agree with the Firebase owner on:

- Firebase app configuration and the permitted auth providers, college email domain and verification flow. Confirm how profile setup resumes across devices and sessions.
- Profile/role fields and who may write them. Document and photo paths, accepted file types, and who may read them.
- Rides, passenger requests, group membership and invitations, chat, notifications, blocked accounts, ratings and reports. Supply field names, types, statuses, query/index requirements, ownership rules and backend actions.
- The server-authoritative operation that accepts or rejects requests, prevents duplicates and reserves seats under simultaneous requests. Include how vehicle capacity, cancellation and leaving a group work.
- Fare currency and representation, such as integer paisa or another agreed numerical format.

## Verification

The unchanged ride model has an included Dart check for matching and group admission. It covers an eligible ride 35 minutes away, unrelated and distant pickups, nearby GPS coordinates, wrong destination/date, past or out-of-window departures, and duplicate and full-group admission. Flutter builds, physical GPS, profile photo access, layout at multiple device sizes and multi-account Firebase behavior require device testing.
