class ApiEndpoints {
  // =====================
  // GANTI DENGAN MILIKMU
  // =====================
  static const String supabaseUrl = 'https://cwaqmjqupgbscrwrsclc.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3YXFtanF1cGdic2Nyd3JzY2xjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2ODkzNjYsImV4cCI6MjA5MjI2NTM2Nn0.7kIZo0J0TWoigRglshu256duXkc3r40yDn7jM3sJlpg';

  // =====================
  // Supabase Table Names
  // =====================
  static const String usersTable = 'users';
  static const String ticketsTable = 'tickets';
  static const String commentsTable = 'comments';
  static const String notificationsTable = 'notifications';

  // =====================
  // Supabase Storage Buckets
  // =====================
  static const String attachmentsBucket = 'attachments';
  static const String avatarsBucket = 'avatars';
}