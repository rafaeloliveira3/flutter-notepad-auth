# Bloco de Notas — Flutter + Supabase

Aplicativo de notas pessoais desenvolvido em Flutter com autenticação e banco de dados via Supabase.

---

## Descrição

O **Bloco de Notas** é um sistema de notas pessoais multiplataforma (Android, iOS e Web) que permite ao usuário criar, visualizar, editar e deletar anotações de forma segura, com cada nota vinculada ao seu perfil autenticado.

---

## Funcionalidades Principais

- **Autenticação completa**: cadastro, login e logout com email e senha
- **CRUD de notas**: criar, listar, editar e excluir notas
- **Proteção de rotas**: telas acessíveis apenas por usuários autenticados
- **Pull-to-refresh**: atualização manual da lista
- **Validação de formulários**: campos obrigatórios e formatos corretos

---

## Tecnologias Utilizadas

| Tecnologia | Finalidade |
|---|---|
| Flutter | Framework UI multiplataforma |
| Dart | Linguagem de programação |
| Supabase Flutter `^2.5.0` | Autenticação e banco de dados |
| Supabase Auth | Login / Cadastro / Logout |
| Supabase Database (PostgreSQL) | Persistência das notas |
| Row Level Security (RLS) | Isolamento de dados por usuário |

---

## Estrutura de Arquivos

```
lib/
├── main.dart                   # Ponto de entrada + inicialização Supabase
├── models/
│   └── note.dart               # Modelo de dados da nota
├── utils/
│   └── error_translator.dart   # Tradução de erros do supabase auth
├── screens/
│   ├── login_screen.dart       # Tela de login
│   ├── register_screen.dart    # Tela de cadastro
│   ├── home_screen.dart        # Lista de notas (Home)
│   └── note_form_screen.dart   # Formulário criar/editar nota
└── widgets/
    └── note_card.dart          # Card reutilizável de nota
```

---

## Tutorial: Configurando o Supabase

### 1. Criar o Projeto no Supabase

1. Acesse [https://supabase.com](https://supabase.com) e faça login (ou crie uma conta)
2. Clique em **"New Project"**
3. Preencha:
   - **Name**: `notas-pdm` (ou o nome que preferir)
   - **Database Password**: defina uma senha forte
   - **Region**: escolha o mais próximo de você (ex: `South America (São Paulo)`)
4. Clique em **"Create new project"** e aguarde a criação (pode levar 1–2 minutos)

---

### 2. Coletar as Credenciais

Após criado o projeto:

1. Anote os valores:
   - **Project URL** → `https://xxxxxxxxxxx.supabase.co`
   - **anon public key** → chave longa que começa com `eyJ...`

---

### 3. Criar a Tabela de Notas

No menu lateral, clique em **SQL Editor** e execute o SQL abaixo:

```sql
-- Cria a tabela de notas vinculada ao usuário autenticado
CREATE TABLE notes (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title      text NOT NULL,
  content    text NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Habilita Row Level Security (RLS)
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Policy: usuário vê apenas suas próprias notas
CREATE POLICY "Users can view own notes"
  ON notes FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

-- Policy: usuário insere apenas notas com seu próprio user_id
CREATE POLICY "Users can insert own notes"
  ON notes FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

-- Policy: usuário atualiza apenas suas próprias notas
CREATE POLICY "Users can update own notes"
  ON notes FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

-- Policy: usuário deleta apenas suas próprias notas
CREATE POLICY "Users can delete own notes"
  ON notes FOR DELETE
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);
```

> **O que é Row Level Security (RLS)?**  
> É uma camada de segurança do PostgreSQL que garante que cada usuário acesse **apenas seus próprios dados**, mesmo que alguém tente consultar o banco diretamente pela API. Sem RLS ativo, qualquer usuário autenticado poderia ver as notas de outros.

---

### 4. Conectar o Flutter ao Supabase

Abra o arquivo `lib/main.dart` e substitua as credenciais pelas anotadas anteriormente:

```dart
await Supabase.initialize(
  url: 'https://SEU_PROJECT_URL.supabase.co', // ← substitua aqui
  anonKey: 'SUA_ANON_KEY',                    // ← substitua aqui
);
```

---

## Como Executar o Projeto

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (versão 3.0+)
- Um dispositivo, emulador Android ou simulador iOS configurado (pode ser executado no navegador também)
- Credenciais do Supabase configuradas (etapas acima)

### Passo a passo

```bash
# 1. Clone ou baixe o projeto
cd flutter-notepad-auth

# 2. Instale as dependências
flutter pub get

# 3. Execute o aplicativo
flutter run
```

---

## Como Funciona a Autenticação

A autenticação é gerenciada 100% pelo **Supabase Auth**:

| Ação | Implementação |
|---|---|
| **Cadastro** | `supabase.auth.signUp(email, password)` |
| **Login** | `supabase.auth.signInWithPassword(email, password)` |
| **Logout** | `supabase.auth.signOut()` |
| **Verificar sessão** | `supabase.auth.currentUser` |

Ao abrir o app, o `main.dart` verifica se já existe uma sessão ativa:
- **Sem sessão** → redireciona para `LoginScreen`
- **Com sessão** → redireciona diretamente para `HomeScreen`

---

## Banco de Dados

As notas são armazenadas no PostgreSQL do Supabase com isolamento por `user_id`. Os métodos implementados são:

| Operação | Método Supabase |
|---|---|
| **Listar notas** | `.from('notes').select().eq('user_id', userId)` |
| **Criar nota** | `.from('notes').insert({...}).select().single()` |
| **Editar nota** | `.from('notes').update({...}).eq('id', id)` |
| **Deletar nota** | `.from('notes').delete().eq('id', id)` |

---

## Telas do App

| Tela | Descrição |
|---|---|
| **Login** | Email + senha com validação e link para cadastro |
| **Cadastro** | Email, senha e confirmação com feedback visual |
| **Home** | Lista de notas com pull-to-refresh |
| **Formulário** | Criar ou editar nota |

---

## Observações

- As notas são **privadas por padrão** graças ao RLS — cada usuário vê apenas as suas
- Nunca compartilhe a `service_role` key no cliente Flutter; use sempre a `anon` key
- Para publicar o app, configure confirmação de e-mail e SMTP no painel do Supabase
