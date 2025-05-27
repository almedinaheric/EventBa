import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String imageUrl;
  final String eventName;
  final String location;
  final String date;
  final bool isPaid;
  final bool isFeatured;
  final bool isFavoriteEvent;
  final double height;
  final double width;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.imageUrl,
    required this.eventName,
    required this.location,
    required this.date,
    this.isPaid = false,
    this.isFeatured = false,
    this.isFavoriteEvent = false,
    this.height = 130,
    this.width = double.infinity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background image
              Image.asset(
                imageUrl,
                height: height,
                width: width,
                fit: BoxFit.cover,
              ),

              // Dark overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Top row: date + badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaid ? const Color(0xFF4776E6) : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPaid ? "PAID" : "FREE",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom left: name + location
              Positioned(
                left: 16,
                right: isFavoriteEvent ? 40 : 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Bottom right: red heart if favorite
              if (isFavoriteEvent)
                const Positioned(
                  bottom: 16,
                  right: 16,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}