import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String imageUrl;
  final String eventName;
  final String location;
  final String date;
  final bool isMyEvent;
  final String? myEventStatus;
  final bool isPaid;
  final bool isFeatured;
  final bool isFavoriteEvent;
  final double height;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const EventCard({
    super.key,
    required this.imageUrl,
    required this.eventName,
    required this.location,
    required this.date,
    this.isMyEvent = false,
    this.myEventStatus,
    this.isPaid = false,
    this.isFeatured = false,
    this.isFavoriteEvent = false,
    this.height = 130,
    this.width = double.infinity,
    this.onTap,
    this.onFavoriteToggle,
  }) : assert(
  isMyEvent == false || (myEventStatus != null),
  "myEventStatus must be provided if isMyEvent is true",
  );

  @override
  Widget build(BuildContext context) {
    final String badgeText;
    final Color badgeColor;

    if (isMyEvent) {
      badgeText = myEventStatus!.toUpperCase();
      badgeColor = badgeText == "UPCOMING" ? Colors.green : Colors.grey;
    } else {
      badgeText = isPaid ? "PAID" : "FREE";
      badgeColor = isPaid ? const Color(0xFF4776E6) : Colors.green;
    }

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
              Image.asset(
                imageUrl,
                height: height,
                width: width,
                fit: BoxFit.cover,
              ),
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
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
              if (isFavoriteEvent)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                      size: 32,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

