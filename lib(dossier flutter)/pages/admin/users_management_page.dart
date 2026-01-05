import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class UsersManagementPage extends StatefulWidget {
  final AuthService authService;

  UsersManagementPage({Key? key, required this.authService}) : super(key: key);

  @override
  _UsersManagementPageState createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      print(' Token: ${widget.authService.token}');
      print(' Current user: ${widget.authService.currentUser?.email}');
      print(' Is admin: ${widget.authService.currentUser?.isAdmin}');
      print(' Roles: ${widget.authService.currentUser?.roles}');
      
      final users = await widget.authService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print(' Erreur chargement utilisateurs: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de récupération des utilisateurs: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteUser(String email) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'utilisateur $email ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Oui, supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.authService.deleteUser(email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' Utilisateur supprimé'), backgroundColor: Colors.green),
        );
        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showCreateUserDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nomController = TextEditingController();
    final prenomController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedRole = 'ETUDIANT';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Créer un utilisateur'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Rôle',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'ETUDIANT', child: Text('Étudiant')),
                      DropdownMenuItem(value: 'PROFESSEUR', child: Text('Professeur')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('Administrateur')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Email requis' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) => value == null || value.isEmpty ? 'Mot de passe requis' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Nom requis' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: prenomController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Prénom requis' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await widget.authService.createUser(
                      emailController.text,
                      passwordController.text,
                      nomController.text,
                      prenomController.text,
                      selectedRole,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(' Utilisateur créé avec succès'), backgroundColor: Colors.green),
                    );
                    _loadUsers();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditUserDialog(User user) async {
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();
    final nomController = TextEditingController(text: user.nom);
    final prenomController = TextEditingController(text: user.prenom);
    final formKey = GlobalKey<FormState>();
    String selectedRole = user.roles?.first.replaceAll('ROLE_', '') ?? 'ETUDIANT';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Modifier l\'utilisateur'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Rôle',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'ETUDIANT', child: Text('Étudiant')),
                      DropdownMenuItem(value: 'PROFESSEUR', child: Text('Professeur')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('Administrateur')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe (optionnel)',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      hintText: 'Laisser vide pour ne pas changer',
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Nom requis' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: prenomController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Prénom requis' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await widget.authService.updateUser(
                      emailController.text,
                      passwordController.text.isEmpty ? null : passwordController.text,
                      nomController.text,
                      prenomController.text,
                      selectedRole,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(' Utilisateur modifié avec succès'), backgroundColor: Colors.green),
                    );
                    _loadUsers();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(User user) {
    if (user.isAdmin) return Colors.red;
    if (user.isProfesseur) return Colors.blue;
    return Colors.green;
  }

  IconData _getRoleIcon(User user) {
    if (user.isAdmin) return Icons.admin_panel_settings;
    if (user.isProfesseur) return Icons.school;
    return Icons.person;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // En-tête avec bouton créer professeur
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_users.length} utilisateur(s)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateUserDialog,
                icon: Icon(Icons.add),
                label: Text('Créer un utilisateur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),

        // Liste des utilisateurs
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadUsers,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final isCurrentUser = user.email == widget.authService.currentUser?.email;

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRoleColor(user),
                      child: Icon(_getRoleIcon(user), color: Colors.white),
                    ),
                    title: Text(
                      '${user.prenom} ${user.nom}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(user.email ?? ''),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.roleDisplay,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getRoleColor(user),
                            ),
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: isCurrentUser
                        ? Chip(
                            label: Text('Vous', style: TextStyle(fontSize: 11)),
                            backgroundColor: Colors.amber.shade100,
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditUserDialog(user),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteUser(user.email ?? ''),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
