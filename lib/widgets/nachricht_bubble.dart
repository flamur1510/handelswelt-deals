import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NachrichtBubble extends StatelessWidget {
  final bool vonMir;
  final String text;
  final String? bildUrl;
  final VoidCallback? onBildTap;

  const NachrichtBubble({
    super.key,
    required this.vonMir,
    required this.text,
    this.bildUrl,
    this.onBildTap,
  });

  @override
  Widget build(BuildContext context) {
    final hatBild =
        bildUrl != null && bildUrl!.trim().isNotEmpty;

    return Align(
      alignment:
          vonMir ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width * 0.65,
        ),
        decoration: BoxDecoration(
          color: vonMir
              ? Colors.blue.shade600
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
            ),
          ],
        ),
        child: hatBild
            ? GestureDetector(
                onTap: onBildTap,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),
                  child: CachedNetworkImage(imageUrl: 
                    bildUrl!,
                    width: 280,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: vonMir
                      ? Colors.white
                      : Colors.black,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}