import 'package:flutter/material.dart';

class MarketIndexCard extends StatelessWidget {
  final String name;
  final double current;
  final double change;
  final double changePercent;
  final bool isSelected;
  final VoidCallback onTap;

  const MarketIndexCard({
    super.key,
    required this.name,
    required this.current,
    required this.change,
    required this.changePercent,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final color = isPositive ? Colors.red : Colors.green;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              current.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  change.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 