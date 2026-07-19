import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/user_management_provider.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().fetchUsers();
    });
  }

  Future<void> _refresh() async {
    await context.read<UserManagementProvider>().fetchUsers();
  }

  String _titleFor(UserModel user) {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return user.email;
  }

  String _subtitleFor(UserModel user) {
    return '${user.email} • ${user.role}';
  }

  String _initialFor(UserModel user) {
    final source = (user.displayName?.trim().isNotEmpty == true)
        ? user.displayName!.trim()
        : user.email;
    return source.isNotEmpty ? source[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestion des utilisateurs'),
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: Builder(
              builder: (context) {
                if (provider.isLoading && provider.users.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 240),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  );
                }

                if (provider.users.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 240,
                        child: const Center(child: Text('Aucun utilisateur.')),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: provider.users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = provider.users[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(_initialFor(user)),
                      ),
                      title: Text(_titleFor(user)),
                      subtitle: Text(_subtitleFor(user)),
                      trailing: Switch(
                        value: user.isActive,
                        onChanged: (_) {
                          context
                              .read<UserManagementProvider>()
                              .toggleActive(user);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UserFormScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
