import 'package:flutter/material.dart';

class FAQDropdown extends StatelessWidget {
  final List<String> faqs;
  final Function(String) onFAQSelected;

  const FAQDropdown({
    super.key,
    required this.faqs,
    required this.onFAQSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: faqs.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          return ListTile(
            dense: true,
            title: Text(
              faqs[index],
              style: const TextStyle(fontSize: 14),
            ),
            leading: const Icon(Icons.help_outline, size: 20),
            onTap: () => onFAQSelected(faqs[index]),
          );
        },
      ),
    );
  }
}
