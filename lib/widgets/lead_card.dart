// import 'package:flutter/material.dart';
// import 'package:boostseller/config/constants.dart';
// import 'package:boostseller/widgets/button_effect.dart';
// import 'package:boostseller/model/lead_model.dart';
// import 'package:boostseller/services/navigation_services.dart';
// import 'package:boostseller/utils/toast.dart';

// class LeadCard extends StatelessWidget {
//   final String role;
//   final LeadModel lead;

//   const LeadCard({super.key, required this.role, required this.lead});

//   @override
//   Widget build(BuildContext context) {
//     return EffectButton(
//       onTap: () {
//         if (role == 'performer') {
//           if (lead.status == "Assigned") {
//             NavigationService.pushNamed(
//               '/performer-assigned-lead-detail',
//               arguments: {'lead': lead},
//             );
//           } else if (lead.status == "pedding") {
//             ToastUtil.success("Developing...");
//           } else if (lead.status == "Completed") {
//             NavigationService.pushNamed(
//               '/lead-completed',
//               arguments: {'interestId': lead.interestId},
//             );
//           } else if (lead.status == "Closed") {
//             NavigationService.pushNamed(
//               '/lead-closed',
//               arguments: {'stageId': lead.stageId},
//             );
//           } else {
//             NavigationService.pushNamed(
//               '/sales-stage',
//               arguments: {'lead': lead},
//             );
//           }
//         } else {
//           NavigationService.pushNamed(
//             '/hostess-lead-detail',
//             arguments: {'lead': lead},
//           );
//         }
//       },
//       child: Container(
//         width: double.infinity,
//         margin: const EdgeInsets.only(top: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Config.leadCardColor,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black45,
//               blurRadius: 6,
//               offset: Offset(0, 2),
//             ),
//           ],

//           border:
//               lead.status.toLowerCase() == 'pendding'
//                   ? Border.all(color: Colors.orangeAccent, width: 1)
//                   : null,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Name and status
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   lead.name,
//                   style: const TextStyle(
//                     fontSize: Config.leadNameFontSize,
//                     fontWeight: FontWeight.bold,
//                     color: Config.leadNameColor,
//                   ),
//                 ),

//                 Row(
//                   children: [
//                     if (lead.isReturn) ...[
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.purple,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Text(
//                           'Return',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10), // Just 2px between badges
//                     ],
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _getStatusColor(lead.status),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         lead.status,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(lead.interest, style: const TextStyle(color: Colors.white)),
//             const SizedBox(height: 4),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(lead.phone, style: const TextStyle(color: Colors.white60)),
//                 Text(lead.date, style: const TextStyle(color: Colors.white60)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'assigned':
//         return Colors.blue;
//       case 'closed':
//         return Colors.red;
//       case 'completed':
//         return Colors.green;
//       case 'pendding':
//         return Colors.orangeAccent;
//       default:
//         return Colors.indigo;
//     }
//   }
// }

import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/model/lead_model.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/utils/translator_helper.dart';

class LeadCard extends StatefulWidget {
  final String role;
  final LeadModel lead;
  final String langCode;

  const LeadCard({
    super.key,
    required this.role,
    required this.lead,
    required this.langCode,
  });

  @override
  State<LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends State<LeadCard> {
  String? translatedName;
  String? translatedStatus;
  String? translatedInterest;

  @override
  void initState() {
    super.initState();
    _translateLeadFields();
  }

  @override
  void didUpdateWidget(covariant LeadCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.langCode != widget.langCode ||
        oldWidget.lead.status != widget.lead.status) {
      _translateLeadFields();
    }
  }

  Future<void> _translateLeadFields() async {
    final name = await TranslatorHelper.translateText(
      widget.lead.name,
      widget.langCode,
    );
    final status = await TranslatorHelper.translateText(
      widget.lead.status,
      widget.langCode,
    );
    final interest = await TranslatorHelper.translateText(
      widget.lead.interest,
      widget.langCode,
    );

    if (mounted) {
      setState(() {
        translatedName = name;
        translatedStatus = status;
        translatedInterest = interest;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;

    return EffectButton(
      onTap: () {
        if (widget.role == 'performer') {
          if (lead.status == "Assigned") {
            NavigationService.pushNamed(
              '/performer-assigned-lead-detail',
              arguments: {'lead': lead},
            );
          } else if (lead.status == "pedding") {
            ToastUtil.success("Developing...");
          } else if (lead.status == "Completed") {
            NavigationService.pushNamed(
              '/lead-completed',
              arguments: {'interestId': lead.interestId},
            );
          } else if (lead.status == "Closed") {
            NavigationService.pushNamed(
              '/lead-closed',
              arguments: {'stageId': lead.stageId},
            );
          } else {
            NavigationService.pushNamed(
              '/sales-stage',
              arguments: {'lead': lead},
            );
          }
        } else {
          NavigationService.pushNamed(
            '/hostess-lead-detail',
            arguments: {'lead': lead},
          );
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Config.leadCardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
          border:
              lead.status.toLowerCase() == 'pendding'
                  ? Border.all(color: Colors.orangeAccent, width: 1)
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translatedName ?? lead.name,
                  style: const TextStyle(
                    fontSize: Config.leadNameFontSize,
                    fontWeight: FontWeight.bold,
                    color: Config.leadNameColor,
                  ),
                ),
                Row(
                  children: [
                    if (lead.isReturn) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getText("Return", widget.langCode),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(lead.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        translatedStatus ?? lead.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              translatedInterest ?? lead.interest,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lead.phone, style: const TextStyle(color: Colors.white60)),
                Text(lead.date, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.blue;
      case 'closed':
        return Colors.red;
      case 'completed':
        return Colors.green;
      case 'pendding':
        return Colors.orangeAccent;
      default:
        return Colors.indigo;
    }
  }
}
