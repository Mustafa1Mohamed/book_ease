import 'package:material_ui/material_ui.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
