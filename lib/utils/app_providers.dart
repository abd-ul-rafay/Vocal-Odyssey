import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../providers/child_provider.dart';
import '../providers/level_provider.dart';
import '../providers/user_provider.dart';

final List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (_) => UserProvider()),
  ChangeNotifierProvider(create: (_) => ChildProvider()),
  ChangeNotifierProvider(create: (_) => LevelProvider()),
];
