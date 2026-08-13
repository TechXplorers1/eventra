import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class GuestListScreen extends StatefulWidget {
  final String eventId;
  const GuestListScreen({super.key, required this.eventId});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  String _searchQuery = '';
  String _filterStatus = 'All';

  // Mock guest data
  final List<Map<String, dynamic>> _guests = [
    {
      'id': 'TKT-1001',
      'name': 'John Doe',
      'email': 'john@example.com',
      'type': 'VIP',
      'status': 'Pending',
    },
    {
      'id': 'TKT-1002',
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'type': 'General',
      'status': 'Checked In',
    },
    {
      'id': 'TKT-1003',
      'name': 'Alice Johnson',
      'email': 'alice@example.com',
      'type': 'General',
      'status': 'Pending',
    },
    {
      'id': 'TKT-1004',
      'name': 'Bob Williams',
      'email': 'bob@example.com',
      'type': 'VIP',
      'status': 'Pending',
    },
    {
      'id': 'TKT-1005',
      'name': 'Charlie Brown',
      'email': 'charlie@example.com',
      'type': 'Early Bird',
      'status': 'Checked In',
    },
  ];

  List<Map<String, dynamic>> get _filteredGuests {
    return _guests.where((guest) {
      final matchesSearch = guest['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          guest['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          guest['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesFilter = _filterStatus == 'All' || guest['status'] == _filterStatus;
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _checkInGuest(String ticketId) {
    final index = _guests.indexWhere((g) => g['id'] == ticketId);
    if (index != -1) {
      setState(() {
        _guests[index]['status'] = 'Checked In';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_guests[index]['name']} checked in manually.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final guests = _filteredGuests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.foreground),
          onPressed: () => context.pop(),
        ),
        title: Text('Manage Guest List', style: TextStyle(color: AppColors.foreground, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.card,
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.search, size: 20, color: AppColors.mutedForeground),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: AppColors.foreground),
                          decoration: InputDecoration(
                            hintText: 'Search by name, email, or Ticket ID',
                            hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Pending', 'Checked In'].map((status) {
                      final isSelected = _filterStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _filterStatus = status);
                          },
                          backgroundColor: AppColors.background,
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.mutedForeground,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Guest List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: guests.length,
              itemBuilder: (context, index) {
                final guest = guests[index];
                final isCheckedIn = guest['status'] == 'Checked In';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(guest['name'][0], style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(guest['name'], style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCheckedIn ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            guest['status'],
                            style: TextStyle(
                              color: isCheckedIn ? Colors.green : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(guest['email'], style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(LucideIcons.ticket, size: 12, color: AppColors.mutedForeground),
                              const SizedBox(width: 4),
                              Text('${guest['id']} • ${guest['type']}', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: isCheckedIn 
                        ? null 
                        : IconButton(
                            icon: Icon(LucideIcons.checkCircle, color: AppColors.primary),
                            tooltip: 'Manual Check-in',
                            onPressed: () => _checkInGuest(guest['id']),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
