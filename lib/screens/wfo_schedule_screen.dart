import 'package:flutter/material.dart';
import '../interfaces/schema_type.dart';
import '../models/wfo_schema.dart';
import '../models/user.dart'; // Import your User model
import '../utils/constants.dart';
import '../utils/data_loader.dart';

class WfoScheduleScreen extends StatefulWidget {
  const WfoScheduleScreen({super.key});

  @override
  State<WfoScheduleScreen> createState() => _WfoScheduleScreenState();
}

class _WfoScheduleScreenState extends State<WfoScheduleScreen> {
  List<WFOSchema> _wfoSchemas = [];
  Map<WFOSchema, List<User>> _wfoData = {};
  final Map<String, bool> _expandedStates = {};
  bool _isLoading = true;

  final TextStyle _kTextStyleHeading2 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    _loadWfoData();
  }

  Future<void> _loadWfoData() async {
    try {
      _wfoSchemas = await DataLoader.loadWFOSchemas();
      _wfoData = await DataLoader.loadUsersForWfoSchedule();
      // Initialize expanded states for each schema
      for (var schema in _wfoSchemas) {
        _expandedStates[schema.id.toString()] = false;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching WFO data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WFO Schedule'), // App bar title
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : ListView(children: _buildCategoryList()),
    );
  }

  List<Widget> _buildCategoryList() {
    return _wfoSchemas.map((schema) => _buildCategory(schema)).toList();
  }

  Widget _buildCategory(WFOSchema schema) {
    final String categoryId = schema.id.toString();
    return Column(
      children: [
        ListTile(
          title: Text(schema.name, style: _kTextStyleHeading2),
          subtitle: Text(schema.description),
          trailing: IconButton(
            icon: Icon(
              _expandedStates[categoryId]!
                  ? Icons.arrow_drop_up
                  : Icons.arrow_drop_down,
            ),
            onPressed: () {
              setState(() {
                _expandedStates[categoryId] = !_expandedStates[categoryId]!;
              });
            },
          ),
        ),
        if (_expandedStates[categoryId]!) ..._buildUserList(schema),
      ],
    );
  }

  Widget _buildUserCard(User user) {
    // Enhanced user card with more user information
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              user.imageUrl.isNotEmpty
                  ? NetworkImage(user.imageUrl) as ImageProvider
                  : const AssetImage('assets/images/default_avatar.png'),
        ),
        title: Text(user.name),
        subtitle: Text(user.designation),
      ),
    );
  }

  List<Widget> _buildUserList(WFOSchema schema) {
    List<User> users = _wfoData[schema] ?? [];
    // Check if there are any users and display a message if not
    if (users.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("No User Assigned in this schema"),
        ),
      ];
    }
    return users.map((user) => _buildUserCard(user)).toList();
  }
}
