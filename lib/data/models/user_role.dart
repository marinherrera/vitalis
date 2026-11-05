/// Perfis de acesso do aplicativo.
enum UserRole {
  worker('Trabalhador rural'),
  supervisor('Supervisor');

  const UserRole(this.label);

  final String label;
}
