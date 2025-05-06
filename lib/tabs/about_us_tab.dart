import 'package:flutter/material.dart';
import 'package:re_potential/tabs/home_tab.dart';
import 'package:re_potential/utils/colors.dart';
import 'package:re_potential/widgets/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsTab extends StatefulWidget {
  const AboutUsTab({super.key});

  @override
  State<AboutUsTab> createState() => _AboutUsTabState();
}

class _AboutUsTabState extends State<AboutUsTab> {
  final name = TextEditingController();
  final msg = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextWidget(
          text: 'Contact Us',
          fontSize: 48,
          fontFamily: 'Bold',
        ),
        const SizedBox(
          height: 20,
        ),

        const SizedBox(height: 10),
        // Contact Information
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Address
            ContactInfo(
              icon: Icons.location_on,
              title: "Address",
              details:
                  "Claro M. Recto Avenue, Lapasan, 9000 Cagayan de Oro City, Philippines",
            ),
            // Email
            ContactInfo(
              icon: Icons.email,
              title: "Email",
              details: "ferdieannvaldehuesa@gmail.com",
            ),
            // Phone
            ContactInfo(
              icon: Icons.phone,
              title: "Phone",
              details: "09563473134",
            ),
          ],
        ),
        const SizedBox(height: 40),
        // Contact Form
        SizedBox(
          width: 550,
          child: TextField(
            controller: name,
            decoration: InputDecoration(
              hintText: 'Your Email Address',
              hintStyle:
                  const TextStyle(color: Colors.black45, fontFamily: 'Bold'),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Colors.black, // Border color
                  width: 2.0, // Border width
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        const SizedBox(height: 10),
        // Contact Form
        SizedBox(
          width: 550,
          child: TextField(
            controller: msg,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Message here',
              hintStyle:
                  const TextStyle(color: Colors.black45, fontFamily: 'Bold'),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Colors.black, // Border color
                  width: 2.0, // Border width
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () async {
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: 'ferdieannvaldehuesa@gmail.com',
              queryParameters: {'subject': 'RE Potential', 'body': msg.text},
            );

            if (await canLaunchUrl(emailLaunchUri)) {
              await launchUrl(emailLaunchUri);
            } else {
              print('Could not launch email client');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text(
            "Send Message",
            style: TextStyle(
                fontSize: 16, fontFamily: 'Bold', color: Colors.white),
          ),
        ),
        const SizedBox(height: 40),
        // Footer Text
        const Text(
          "© 2025 RE Potential. All rights reserved.",
          style: TextStyle(
              color: Colors.black26, fontSize: 14, fontFamily: 'Regular'),
        ),
      ],
    );
  }
}
