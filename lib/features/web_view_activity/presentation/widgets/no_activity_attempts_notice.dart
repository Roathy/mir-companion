// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../domain/providers.dart';

// class NoActivityAttemptsNotice extends StatelessWidget {
//   final bool canBuy;
//   final int? activityId;
//   final String? message;

//   const NoActivityAttemptsNotice(
//       {super.key, required this.canBuy, this.activityId, this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         padding: EdgeInsets.symmetric(horizontal: 30),
//         decoration: BoxDecoration(color: Colors.blue),
//         child: Column(
//             spacing: 12,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Whoa There! Important Notice',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w600),
//               ),
//               Text(
//                 'You have reached the maximum number of attempts for the exercise. 😢',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500),
//               ),
//               Text(
//                 'Please return to the main menu and continue with the next activity.',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500),
//               ),
//               Column(children: [
//                 SizedBox(
//                     width: double.infinity,
//                     child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16.0), // Adjust padding as needed
//                         child: FilledButton(
//                             style: ButtonStyle(
//                               alignment: Alignment.center,
//                               backgroundColor:
//                                   WidgetStateProperty.all(Colors.orange),
//                             ),
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.center, // Centers content
//                                 children: [
//                                   Icon(
//                                     Icons.navigate_before,
//                                     color: Colors.white,
//                                     size: 30,
//                                   ),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     'Exit to the menu',
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 18),
//                                   )
//                                 ])))),
//                 if (canBuy)
//                   SizedBox(
//                       width: double.infinity,
//                       child: Consumer(
//                         builder: (context, ref, child) {
//                           final buyAttemptState =
//                               ref.watch(buyAttemptStateProvider);
//                           // Show success or error messages
//                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                             if (buyAttemptState == BuyAttemptState.success) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                     content: Text(
//                                         "✅ Extra attempt purchased successfully!"),
//                                     backgroundColor: Colors.green),
//                               );
//                             } else if (buyAttemptState ==
//                                 BuyAttemptState.error) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                     content:
//                                         Text("❌ Failed to purchase attempt!"),
//                                     backgroundColor: Colors.red),
//                               );
//                             }
//                           });

//                           return ElevatedButton(
//                               onPressed:
//                                   buyAttemptState == BuyAttemptState.loading
//                                       ? null
//                                       : () async {
//                                           await buyExtraAttempt(ref, activityId!);
//                                         },
//                               style: ButtonStyle(
//                                   alignment: Alignment.center,
//                                   backgroundColor:
//                                       WidgetStateProperty.all(Colors.green)),
//                               child: buyAttemptState == BuyAttemptState.loading
//                                   ? CircularProgressIndicator(
//                                       color: Colors.white)
//                                   : Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                           Icon(Icons.star,
//                                               color: Colors.white, size: 30),
//                                           SizedBox(width: 8),
//                                           Text(message!,
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.w700,
//                                                   fontSize: 18))
//                                         ]));
//                         },
//                       ))
//               ])
//             ]));
//   }
// }
