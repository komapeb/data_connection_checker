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
