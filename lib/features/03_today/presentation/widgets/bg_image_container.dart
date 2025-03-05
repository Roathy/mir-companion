import 'package:flutter/material.dart';

class BgImageContainer extends StatelessWidget {
  final double? height, width, borderRadius;
  final num? heightMultiplier, widthMultiplier;
  final String imageUrl;
  final Widget? content;

  const BgImageContainer({
    super.key,
    required this.imageUrl,
    this.content,
    this.height,
    this.width,
    this.borderRadius = 9,
    this.heightMultiplier = 0.30,
    this.widthMultiplier = 0.90,
  });

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define default height and width as a percentage of the screen size
    final defaultHeight =
        height ?? screenHeight * heightMultiplier!; // 30% of screen height
    final defaultWidth =
        width ?? screenWidth * widthMultiplier!; // 90% of screen width

    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        height: defaultHeight,
        width: defaultWidth,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius!),
              ),
              alignment: Alignment.center,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: defaultWidth,
                height: defaultHeight,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Icon(Icons.error, color: Colors.red);
                },
              ),
            ),
          ),
          Positioned.fill(
            child: content ?? Container(),
          ),
        ],
      ),
    );
  }
}
