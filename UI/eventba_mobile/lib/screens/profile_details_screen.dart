import 'package:flutter/material.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController bioController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTextField("Full Name", nameController),
          _buildTextField("Email", emailController),
          _buildTextField("Phone Number", phoneController),
          _buildTextField("Bio", bioController, maxLines: 3),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Save profile logic
            },
            child: const Text("Save Changes"),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
