/// Travel category / mood entity.
/// No Flutter / framework dependencies.
class Category {
  final String id;
  final String name;
  final String icon; // logical icon key, resolved in the UI layer

  const Category({
    required this.id,
    required this.name,
    required this.icon,
  });
}
