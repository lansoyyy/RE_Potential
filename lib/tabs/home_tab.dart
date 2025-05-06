import 'package:flutter/material.dart';
import 'package:re_potential/tabs/about_us_tab.dart';
import 'package:re_potential/utils/colors.dart';
import 'package:re_potential/widgets/text_widget.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<String> imageUrls = [
    'images (9)',
    'MariaCristinaFallsJuly2006',
    'images (15)',
    'images (16)',
  ];

  final List<String> details = [
    'Similar to the rest of the Philippines, Misamis Oriental benefits from high solar irradiance year-round. Solar farms and rooftop solar systems can be deployed to power urban centers and remote rural communities.',
    'The province has several rivers, including the municipalities of Tagoloan and Villanueva, this river has strong water flow and is already partially utilized for industrial purposes and suitable for small to medium-scale hydropower projects. These can provide consistent and clean energy, supporting agricultural and industrial operations.',
    'Coastal winds along Macajalar Bay and elevated areas in Misamis Oriental offer viable locations for wind energy projects. While less tapped in the Philippines, this resource can diversify the local energy mix.',
    "The province's strong agricultural base generates residues like rice husks, coconut shells, and sugarcane waste, which can be converted into biomass energy. This provides a dual benefit of sustainable waste management and energy production.",
  ];
  final PageController _pageController = PageController(
    viewportFraction: 0.8, // Adjust the size of images in the viewport
    initialPage: 0,
  );

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Add an automatic page change timer (optional)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
  }

  void _autoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      int nextPage = (_currentPage + 1) % imageUrls.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage = nextPage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/images (6).jpeg',
                height: 300,
              ),
              const SizedBox(
                width: 50,
              ),
              SizedBox(
                width: 500,
                child: TextWidget(
                  maxLines: 100,
                  text:
                      'The Philippines is endowed with abundant renewable energy resources, including solar, hydro, wind, geothermal, and biomass. With its archipelagic geography and tropical climate, the country is well-positioned to harness these resources to support its growing energy demand while reducing reliance on imported fossil fuels.',
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextWidget(
                    text: _currentPage == 0
                        ? 'Solar Energy'
                        : _currentPage == 1
                            ? 'Hyropower'
                            : _currentPage == 2
                                ? 'Wind Energy'
                                : 'Biomass Energy',
                    fontSize: 32,
                    fontFamily: 'Bold',
                  ),
                  SizedBox(
                    width: 500,
                    child: TextWidget(
                      maxLines: 100,
                      text: details[_currentPage],
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 50,
              ),
              SizedBox(
                  width: 500,
                  height: 300,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double value = 1.0;
                                if (_pageController.position.haveDimensions) {
                                  value = (_pageController.page! - index).abs();
                                  value = (1 - value).clamp(0.0, 1.0);
                                }
                                return Transform.scale(
                                  scale: 0.9 +
                                      value *
                                          0.1, // Adjust the scale of the image
                                  child: child,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 20.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image.asset(
                                    index == 1
                                        ? 'assets/images/${imageUrls[index]}.jpg'
                                        : 'assets/images/${imageUrls[index]}.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imageUrls.length, (index) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          );
                        }),
                      )
                    ],
                  ))
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/images (8).jpeg',
                height: 300,
              ),
              const SizedBox(
                width: 50,
              ),
              SizedBox(
                width: 500,
                child: TextWidget(
                  maxLines: 100,
                  text:
                      "Misamis Oriental, situated in Northern Mindanao, is known for its vibrant economy, lush landscapes, and coastal proximity to Macajalar Bay. Its diverse natural resources and strategic location make it an ideal hub for renewable energy development, mirroring the country's overall potential.",
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(),
          Container(
            width: double.infinity,
            height: 500,
            decoration: const BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                  opacity: 0.5,
                  image: AssetImage(
                    'assets/images/images (18).jpeg',
                  ),
                  fit: BoxFit.cover),
            ),
            child: Center(
              child: SizedBox(
                width: 600,
                child: TextWidget(
                  align: TextAlign.center,
                  maxLines: 50,
                  text:
                      "Misamis Oriental reflects the Philippines' vast renewable energy potential, with its rich solar, hydro, wind, and biomass resources poised to drive sustainable energy development for the region and beyond.",
                  fontSize: 32,
                  fontFamily: 'Bold',
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(),
          const SizedBox(
            height: 20,
          ),
          const AboutUsTab(),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}

class ContactInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String details;

  const ContactInfo({
    super.key,
    required this.icon,
    required this.title,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: primary, size: 40),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Bold',
          ),
        ),
        const SizedBox(height: 5),
        Text(
          details,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black38,
            fontSize: 14,
            fontFamily: 'Medium',
          ),
        ),
      ],
    );
  }
}
