import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Image with Text Overlay
              Stack(
                children: [
                  Image.asset(
                    'assets/header_image.jpg', // replace with your header image
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Text(
                        'About Us',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Our Vision
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/robot.png', // replace with your image
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Our Vision',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'To transform electronic shopping into a seamless, transparent, and personalized experience, empowering users with innovative, user-centric solutions for confident and informed decisions.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Our Mission
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Our Mission',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Our mission is to simplify shopping with innovative solutions, offering personalized recommendations, transparent information, and reliable support for a smart and seamless experience.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      'assets/watch.png', // replace with your image
                      width: 80,
                      height: 80,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // The Story
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The SmartShopper Story',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'It all started with a simple yet frustrating problem—every time we wanted to buy electronics\n\n'
                      'we faced the same hurdles. Sometimes, we’d get misled by deals that weren’t really deals.\n\n'
                      'Other times, we’d discover too late that there was a better offer somewhere else.',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}