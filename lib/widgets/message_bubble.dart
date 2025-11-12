import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(String) onFeedback;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.smart_toy, size: 18, color: Colors.grey),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFF8B8B8B)
                        : const Color(0xFFB8B8B8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 18, color: Colors.grey),
                ),
              ],
            ],
          ),
          
          // Timestamp
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: message.isUser ? 0 : 40,
              right: message.isUser ? 40 : 0,
            ),
            child: Text(
              timeFormat.format(message.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ),

          // Feedback buttons for AI messages
          if (!message.isUser)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 40),
              child: Row(
                children: [
                  _FeedbackButton(
                    icon: Icons.thumb_up_outlined,
                    label: 'Support',
                    isSelected: message.feedback == 'support',
                    onTap: () => onFeedback('support'),
                  ),
                  const SizedBox(width: 8),
                  _FeedbackButton(
                    icon: Icons.thumb_down_outlined,
                    label: "Don't Support",
                    isSelected: message.feedback == 'dont_support',
                    onTap: () => onFeedback('dont_support'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.blue : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
