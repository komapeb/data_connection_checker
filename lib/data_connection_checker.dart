/// A pure Dart utility library that checks for an internet connection
/// by opening a socket to a list of specified addresses, each with individual
/// port and timeout. Defaults are provided for convenience.
library data_connection_checker;

import 'package:universal_io/io.dart';
import 'dart:async';
part 'status_enum.dart';
part 'address_check_options.dart';
part 'address_check_result.dart';
part 'data_connection.dart';
