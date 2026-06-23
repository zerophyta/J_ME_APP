import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "Welcome to J_ME",
      "desc": "Your cinematic chat app with gold & dark blue identity.",
    },
    {
      "title": "Chats & Groups",
      "desc": "Private chats and group conversations with real-time updates.",
    },
    {
      "title": "Media Sharing",
      "desc": "Send images, videos, audio, and documents easily.",
    },
    {
      "title": "Privacy & Secret Chats",
      "desc": "Control visibility and enjoy encrypted self-destruct chats.",
    },
    {
      "title": "Customization",
      "desc": "Change fonts, bubble styles, and wallpapers for your vibe.",
    },
  ];

  void _nextPage() {
    if (currentPage < pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      Navigator.pushReplacementNamed(context, "/signup");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        onPageChanged: (index) => setState(() => currentPage = index),
        itemBuilder: (context, index) {
          final page = pages[index];
          return Container(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(page["title"]!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber)),
                const SizedBox(height: 20),
                Text(page["desc"]!, style: const TextStyle(fontSize: 18, color: Colors.white), textAlign: TextAlign.center),
                const SizedBox(height: 40),
                ElevatedButton(onPressed: _nextPage, child: Text(index == pages.length - 1 ? "Get Started" : "Next")),
              ],
            ),
          );
        },
      ),
    );
  }
}
