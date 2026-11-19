import 'package:material_ui/material_ui.dart';

class ExploreLoadingView extends StatelessWidget {
  const ExploreLoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}
