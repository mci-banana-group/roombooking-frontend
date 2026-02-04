import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/auth_models.dart';
import '../Services/admin_repository.dart';
import '../Resources/AppColors.dart';
import 'AdminUserBookingsScreen.dart';
import '../Constants/layout_constants.dart';

class AdminUserManagement extends ConsumerStatefulWidget {
  const AdminUserManagement({super.key});

  @override
  ConsumerState<AdminUserManagement> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends ConsumerState<AdminUserManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedRole = "ALL"; // "ALL" means all roles

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LayoutConstants.kMaxContentWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      controller: _searchController,
                      hintText: "Search by name or email...",
                      leading: const Icon(Icons.search),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      trailing: [
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildRoleFilter(colorScheme),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // User List
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  final filteredUsers = users.where((user) {
                    final matchesSearch = user.firstName.toLowerCase().contains(_searchQuery) ||
                                       user.lastName.toLowerCase().contains(_searchQuery) ||
                                       user.email.toLowerCase().contains(_searchQuery);
                    
                    final userRole = user.role.trim().toUpperCase();
                    final filterRole = _selectedRole.toUpperCase();
                    
                    bool matchesRole;
                    if (filterRole == "ALL") {
                      matchesRole = true;
                    } else if (filterRole == "ADMIN") {
                      matchesRole = user.isAdmin;
                    } else {
                      matchesRole = userRole == filterRole;
                    }
                    
                    return matchesSearch && matchesRole;
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_off_outlined, size: 48, color: colorScheme.outline.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text("No users found", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserCard(user, colorScheme, textTheme);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text("Error loading users", style: textTheme.bodyLarge?.copyWith(color: colorScheme.error)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(allUsersProvider),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleFilter(ColorScheme colorScheme) {
    final roles = ["STUDENT", "STAFF", "LECTURER", "ADMIN"];
    
    return PopupMenuButton<String>(
      onSelected: (role) {
        setState(() {
          _selectedRole = role;
        });
      },
      icon: Badge(
        label: const Text("1"),
        isLabelVisible: _selectedRole != "ALL",
        child: Icon(Icons.filter_list, color: _selectedRole != "ALL" ? colorScheme.primary : null),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: "ALL",
          child: Row(
            children: [
              Icon(
                _selectedRole == "ALL" ? Icons.check_circle : Icons.circle_outlined,
                size: 20,
                color: _selectedRole == "ALL" ? colorScheme.primary : colorScheme.outline,
              ),
              const SizedBox(width: 12),
              const Text("All Roles"),
            ],
          ),
        ),
        ...roles.map((role) => PopupMenuItem<String>(
          value: role,
          child: Row(
            children: [
              Icon(
                _selectedRole == role ? Icons.check_circle : Icons.circle_outlined,
                size: 20,
                color: _selectedRole == role ? colorScheme.primary : colorScheme.outline,
              ),
              const SizedBox(width: 12),
              Text(role),
            ],
          ),
        )),
      ],
      tooltip: "Filter by Role",
    );
  }

  Widget _buildUserCard(UserResponse user, ColorScheme colorScheme, TextTheme textTheme) {
    final displayRole = user.isAdmin ? "ADMIN" : user.role.toUpperCase();
    final roleColor = _getRoleColor(displayRole, colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminUserBookingsScreen(user: user),
            ),
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            child: Text(
              user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : "?",
              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            "${user.firstName} ${user.lastName}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            user.email,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: roleColor.withOpacity(0.5)),
            ),
            child: Text(
              displayRole,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: roleColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role, ColorScheme colorScheme) {
    switch (role.toUpperCase()) {
      case "ADMIN":
        return colorScheme.error;
      case "STAFF":
        return colorScheme.primary;
      case "LECTURER":
        return colorScheme.secondary;
      case "STUDENT":
        return colorScheme.tertiary;
      default:
        return colorScheme.outline;
    }
  }
}
