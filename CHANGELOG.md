## 0.3.3 (and 0.3.4)

- Bumping version number, so pub.dev can accept the package
- Add more docs for `onStatusChange`

## 0.3.2

- Fix status not updated bug (`_lastStatus` being set incorrectly)

## 0.3.1

- Fix annoying `dartfmt` warning (perfectionism intensifies)

## 0.3.0

- Added `onStatusChange` stream, which users of this lib can subscribe to
  and listen for status changes. Emit values of `DataConnectionStatus`
- Added `checkInterval` which controls how often a check is made
  when someone is listening to `onStatusChange`. Defaults to `DEFAULT_INTERVAL`
  (10 seconds)

## 0.2.1

**Breaking change**
- `hasDataConnection` is now called `hasConnection`

*Non breaking*
- `isHostReachable()` is now public. It allows for individual checks.
- Fix `DEFAULT_ADDRESSES` to be unmodifiable
- removed getter `lastTryLog`
- added getter `connectionStatus`
- added getter `lastTryResults`
- updated example and readme

## 0.2.0

- **Breaking changes**
- This utility is now a Singleton (DataConnectionChecker() always returns the same instance)
as it doesn't make sense to have more than one instance of this class
- `addresses` is a `List<InternetAddressCheckOptions>` now. See the docs for more info
- Each address can now have its own port and timeout assigned.

## 0.1.3

- Add more info in the README

## 0.1.2

- Minor refactoring
- Update README with more info

## 0.1.1

- Remove pedantic as a dependency

## 0.1.0

- Initial version
