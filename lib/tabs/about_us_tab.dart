import 'package:flutter/material.dart';
import 'package:re_potential/tabs/home_tab.dart';
import 'package:re_potential/utils/colors.dart';
import 'package:re_potential/widgets/text_widget.dart';

class AboutUsTab extends StatelessWidget {
  const AboutUsTab({super.key});

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
              details: "123 Main Street\nCity, State, ZIP",
            ),
            // Email
            ContactInfo(
              icon: Icons.email,
              title: "Email",
              details: "contact@example.com",
            ),
            // Phone
            ContactInfo(
              icon: Icons.phone,
              title: "Phone",
              details: "+1 (555) 123-4567",
            ),
          ],
        ),
        const SizedBox(height: 40),
        // Contact Form
        SizedBox(
          width: 550,
          child: TextField(
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
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () {
            // Handle form submission
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
          "© 2024 Your Company. All rights reserved.",
          style: TextStyle(
              color: Colors.black26, fontSize: 14, fontFamily: 'Regular'),
        ),
      ],
    );
  }
}
