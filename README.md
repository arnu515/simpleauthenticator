# simpleauthenticator

Simple TOTP Authenticator

## Download

Get the Android APK file from [Releases](https://github.com/arnu515/simpleauthenticator/releases).

You may get a play-protect warning, and that's because I haven't yet signed the application. This warning can be ignored.

I will publish it soon on F-Droid and Play store.

## Build locally

If you don't have android and want to build for your own system, you can use the `flutter build` command.

```shell
flutter build <platform> --dart-define "API_URL=URL_TO_BACKEND"
```

If you haven't hosted the [backend](https://github.com/arnu515/simpleauthenticator/tree/master/backend) yourself, you can use <https://d13c320db282.up.railway.app>.

To find what platforms are supported, run `flutter build --help`

## Credits

- Logo Icon: <a target="_blank" href="https://icons8.com/icon/40348/lock">Lock</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>
