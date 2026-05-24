import 'package:supabase_flutter/supabase_flutter.dart';

const _translations = {
  'Invalid login credentials': 'Email ou senha incorretos.',
  'Email not confirmed':
      'Email não confirmado. Verifique sua caixa de entrada.',
  'User already registered': 'Este email já está cadastrado.',
  'Password should be at least 6 characters.':
      'A senha deve ter no mínimo 6 caracteres.',
  'Unable to validate email address: invalid format':
      'Formato de email inválido.',
  'Email rate limit exceeded': 'Muitas tentativas. Aguarde alguns minutos.',
  'Invalid email or password': 'Email ou senha incorretos.',
  'Signup is disabled': 'Cadastro desativado. Contate o suporte.',
};

String translateError(Object e) {
  if (e is! AuthException) return 'Erro inesperado. Tente novamente.';
  return _translations[e.message] ?? e.message;
}
