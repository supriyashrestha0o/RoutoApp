// import 'package:flutter/material.dart';
//
// import 'design.dart';
// import 'account.dart';
//
// void main() => runApp(const RoutoApp());

// class RoutoApp extends StatelessWidget {
//   const RoutoApp({super.key});
//
//   @override
//   Widget build(BuildContext context) => MaterialApp(
//     title: 'Routo',
//     debugShowCheckedModeBanner: false,
//     theme: routoTheme(),
//     home: const SplashPage(),
//   );
// }

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});
//
//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }
//
// class _SplashPageState extends State<SplashPage> {
//   @override
//   void initState() {
//     super.initState();
//     Future<void>.delayed(const Duration(milliseconds: 2100), () {
//       if (mounted)
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute<void>(builder: (_) => const OnboardingPage()),
//         );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: const Color(0xff353c34),
//     body: SafeArea(
//       child: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(28),
//           child: Column(
//             children: [
//               Image.asset(
//                 'assets/splash-brand.webp',
//                 height: 240,
//                 semanticLabel: 'Routo student ride sharing',
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Your Route. Your Match.\nYour Journey.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 23,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               const SizedBox(height: 28),
//               Image.asset(
//                 'assets/splash-route.webp',
//                 height: 275,
//                 excludeFromSemantics: true,
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// class WelcomePage extends StatelessWidget {
//   const WelcomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) => Screen(
//     children: [
//       const SizedBox(height: 10),
//       const Text(
//         'яouto',
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           color: forest,
//           fontWeight: FontWeight.w900,
//           fontSize: 50,
//         ),
//       ),
//       const SizedBox(height: 24),
//       const Heading(
//         'Your Journey. Shared Smarter',
//         'Find students traveling the same route and share your journey together.',
//       ),
//       Image.asset(
//         'assets/welcome-ride.webp',
//         height: 230,
//         excludeFromSemantics: true,
//       ),
//       PrimaryAction(
//         'Get Started',
//             () => showPage(context, const RegisterPage()),
//       ),
//       OutlinedButtonTheme(
//         data: OutlinedButtonThemeData(
//           style: OutlinedButton.styleFrom(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//         child: PrimaryAction(
//           'Login',
//               () => showPage(context, const LoginPage()),
//           secondary: true,
//         ),
//       ),
//       TextButton(
//         onPressed: () => showPage(context, const PreviewSetup()),
//         child: const Text('Explore frontend preview'),
//       ),
//     ],
//   );
// }

// class OnboardingPage extends StatefulWidget {
//   const OnboardingPage({super.key});
//
//   @override
//   State<OnboardingPage> createState() => _OnboardingPageState();
// }
//
// class _OnboardingPageState extends State<OnboardingPage> {
//   static const headings = [
//     'Find Students Going Your Way',
//     'Share More Than a Ride',
//     'Ride With People You Can Trust',
//     'Ride Confirmed!',
//   ];
//
//   static const descriptions = [
//     'Discover verified students traveling along similar routes and schedules.',
//     'Request to join, chat with your journey partner, and plan your pickup.',
//     'Connect with verified college students through profiles, journey history, ratings and reviews.',
//     'View your meeting point and coordinate with your journey partner.',
//   ];
//
//   int step = 0;
//
//   @override
//   Widget build(BuildContext context) => Screen(
//     children: [
//       Image.asset(
//         'assets/design-intro-$step.webp',
//         height: 325,
//         excludeFromSemantics: true,
//       ),
//       const SizedBox(height: 26),
//       Heading(headings[step], descriptions[step], teal),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: List.generate(
//           4,
//               (i) => IconButton(
//             tooltip: 'Onboarding page ${i + 1}',
//             onPressed: () => setState(() => step = i),
//             icon: Icon(
//               Icons.circle,
//               size: 8,
//               color: i == step ? teal : Colors.black26,
//             ),
//           ),
//         ),
//       ),
//       PrimaryAction(step == 3 ? 'Get Started' : 'Next', () {
//         if (step == 3) {
//           Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
//             builder: (_) => const WelcomePage(),
//           ));
//         } else {
//           setState(() => step++);
//         }
//       }),
//     ],
//   );
// }
import 'package:flutter/material.dart';

import 'package:routo/app.dart';

void main() => runApp(const RoutoApp());