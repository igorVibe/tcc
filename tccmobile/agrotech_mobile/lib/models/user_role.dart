enum UserRole {
  cliente,
  administrador,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.cliente:
        return 'cliente';

      case UserRole.administrador:
        return 'administrador';
    }
  }

  String get label {
    switch (this) {
      case UserRole.cliente:
        return 'Cliente';

      case UserRole.administrador:
        return 'Administrador';
    }
  }

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'administrador':
      case 'admin':
        return UserRole.administrador;

      case 'cliente':
      default:
        return UserRole.cliente;
    }
  }
}