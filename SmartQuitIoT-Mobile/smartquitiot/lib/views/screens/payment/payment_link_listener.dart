// import 'package:flutter/material.dart';
// import 'dart:async';
//
// class PaymentLinkListener extends StatefulWidget {
//   final Widget child;
//   const PaymentLinkListener({super.key, required this.child});
//
//   @override
//   State<PaymentLinkListener> createState() => _PaymentLinkListenerState();
// }
//
// class _PaymentLinkListenerState extends State<PaymentLinkListener> {
//   StreamSubscription? _sub;
//
//   @override
//   void initState() {
//     super.initState();
//     _handleInitialUri();
//     _sub = uriLinkStream.listen((uri) {
//       _handleIncomingLink(uri);
//     });
//   }
//
//   Future<void> _handleInitialUri() async {
//     final uri = await getInitialUri();
//     _handleIncomingLink(uri);
//   }
//
//   void _handleIncomingLink(Uri? uri) {
//     if (uri == null) return;
//
//     if (uri.path == '/success') {
//       Navigator.pushNamed(context, '/paymentSuccess');
//     } else if (uri.path == '/failed') {
//       Navigator.pushNamed(context, '/paymentFailed');
//     }
//   }
//
//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }
