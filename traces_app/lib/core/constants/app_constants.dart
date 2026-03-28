class AppConstants {
  static const appName = 'Traces';
  static const appVersion = '1.0.0';

  /// Supabase project ref. API base is `https://dcehtpksokxzpjxeecnx.supabase.co` (must match `SUPABASE_URL` in `.env`).
  static const supabaseProjectRef = 'dcehtpksokxzpjxeecnx';

  // Supabase storage buckets
  static const mediaBucket = 'traces-media';
  static const documentsBucket = 'traces-documents';

  // Pagination
  static const defaultPageSize = 20;

  // Loyalty tiers
  static const loyaltyTiers = ['bronze', 'silver', 'gold', 'platinum'];

  // Organizer tiers
  static const organizerTiers = ['new', 'established', 'premier', 'elite'];
}
