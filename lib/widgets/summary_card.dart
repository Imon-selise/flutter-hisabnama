import 'package:flutter/material.dart';
import '../config/constants.dart';
import 'shared_widgets.dart';

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final int tintI;
  const SummaryCard(this.icon, this.label, this.value, this.tintI, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDeco,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: tintFor(tintI), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: inkFor(tintI), size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: kMute, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kInk)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
