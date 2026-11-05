/// Validações dos formulários de login e cadastro.
abstract final class Validators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Informe seu nome.';
    if (text.length < 3) return 'O nome precisa ter pelo menos 3 letras.';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Informe seu e-mail.';
    if (!_emailPattern.hasMatch(text)) {
      return 'Digite um e-mail válido, como nome@empresa.com.';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Informe sua senha.';
    if (text.length < 6) return 'A senha precisa ter pelo menos 6 caracteres.';
    return null;
  }
}
