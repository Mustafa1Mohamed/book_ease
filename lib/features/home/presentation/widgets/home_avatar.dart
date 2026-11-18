import 'package:material_ui/material_ui.dart';

class HomeAvatar extends StatelessWidget {
  const HomeAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    this.fallbackIcon = Icons.person_rounded,
  });

  final String imageUrl;
  final double radius;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: imageUrl.isEmpty
          ? Icon(
              fallbackIcon,
              size: radius,
              color: Theme.of(context).colorScheme.primary,
            )
          : ClipOval(
              child: Image.network(
                imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  fallbackIcon,
                  size: radius,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
    );
  }
}
