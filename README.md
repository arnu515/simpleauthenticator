# simpleauthenticator

Simple TOTP Authenticator

## Download

> **I recommend running the application with `flutter run`, because the APK is not signed**. View instructions below.

Get the Android APK file from [Releases](https://github.com/arnu515/simpleauthenticator/releases).

You may get a play-protect warning, and that's because I haven't yet signed the application. This warning can be ignored.

I will publish it soon on F-Droid and Play store.

## Run locally

You can run the application on Windows, Mac or Linux by using the below command. Make sure to have the [flutter SDK](https://flutter.dev) installed.

```shell
flutter run --dart-define "API_URL=URL_TO_BACKEND"
```

If you haven't hosted the [backend](https://github.com/arnu515/simpleauthenticator/tree/master/backend) yourself, you can use <https://d13c320db282.up.railway.app>.

You can also run the app on Android if you have the Android SDK installed by connecting your phone to your computer and turning on USB debugging, and running the above command.

You can also build the app by replacing `flutter run` with `flutter build <platform>`. To find what platforms are supported, run `flutter build --help`

## Credits

- Logo Icon: <a target="_blank" href="https://icons8.com/icon/40348/lock">Lock</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>
