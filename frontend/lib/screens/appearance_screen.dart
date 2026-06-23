import 'package:flutter/material.dart';
import '../api/api_client.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  final ApiClient api = ApiClient();

  String selectedFont = "Roboto";
  String selectedBubbleStyle = "Rounded";
  String selectedWallpaper = "Default";
  String message = "";

  Future<void> _saveAppearance() async {
    bool success = await api.setAppearance(
      selectedFont,
      selectedBubbleStyle,
      selectedWallpaper,
    );
    setState(() {
      message = success ? "Appearance updated ✅" : "Update failed ❌";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Appearance Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedFont,
              items: ["Roboto", "OpenSans", "Montserrat"].map((font) {
                return DropdownMenuItem(value: font, child: Text(font));
              }).toList(),
              onChanged: (val) => setState(() => selectedFont = val!),
            ),
            DropdownButton<String>(
              value: selectedBubbleStyle,
              items: ["Rounded", "Square", "Gradient"].map((style) {
                return DropdownMenuItem(value: style, child: Text(style));
              }).toList(),
              onChanged: (val) => setState(() => selectedBubbleStyle = val!),
            ),
            DropdownButton<String>(
              value: selectedWallpaper,
              items: ["Default", "Gold Theme", "Dark Blue Theme", "Custom"].map((wall) {
                return DropdownMenuItem(value: wall, child: Text(wall));
              }).toList(),
              onChanged: (val) => setState(() => selectedWallpaper = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveAppearance, child: const Text("Save")),
            Text(message)
          ],
        ),
      ),
    );
  }
}
