import 'package:image/image.dart' as img;  // Importing the 'image' library for image processing
import 'dart:math';  // Importing dart:math for mathematical operations like square root and power
import 'dart:collection';  // Importing 'dart:collection' to use Queue for BFS (breadth-first search)
import 'package:flutter/material.dart';  // Importing Flutter's material design library

// Function to calculate the outline of a region in the image based on color similarity
List<Offset> getOutline(img.Image image, int startX, int startY, double tolerance) {
  final width = image.width;  // Getting the width of the image
  final height = image.height;  // Getting the height of the image
  final visited = List.generate(height, (_) => List<bool>.filled(width, false));  // 2D array to keep track of visited pixels
  final targetColor = image.getPixel(startX, startY);  // Get the color at the starting point (startX, startY)
  final outlinePoints = <Offset>[];  // List to store the points that form the outline

  final queue = Queue<Point<int>>();  // Queue for BFS to explore all connected pixels
  queue.add(Point(startX, startY));  // Adding the starting point to the queue

  print("Starting outline calculation...");  // Debug print to show the start of outline calculation

  // BFS loop to explore each neighboring pixel
  while (queue.isNotEmpty) {
    final point = queue.removeFirst();  // Remove the first point in the queue
    final x = point.x;  // Get the x coordinate of the point
    final y = point.y;  // Get the y coordinate of the point

    // Skip the point if it is out of bounds or already visited
    if (x < 0 || y < 0 || x >= width || y >= height || visited[y][x]) continue;

    visited[y][x] = true;  // Mark the current point as visited
    final currentColor = image.getPixel(x, y);  // Get the color of the current pixel

    // Compare the color of the current pixel to the target color. If the difference exceeds the tolerance, add to the outline
    // Also add the point to the outline if it is right next to the border of the image
    if (_colorDifference(targetColor, currentColor) > tolerance || (x < 1 || y < 1 || x >= width -1 || y >= height -1)) {
      outlinePoints.add(Offset(x.toDouble(), y.toDouble()));  // Add the current point as part of the outline
      continue;  // Continue to the next pixel
    }

    // Add neighboring points to the queue to continue the BFS (right, left, down, up)
    queue.add(Point(x + 1, y));  // Right
    queue.add(Point(x - 1, y));  // Left
    queue.add(Point(x, y + 1));  // Down
    queue.add(Point(x, y - 1));  // Up
  }

  print("Outline calculation complete. Points found: ${outlinePoints.length}");  // Debug print to show the end of outline calculation and how many points were found
  return outlinePoints;  // Return the list of outline points
}

// Helper function to calculate the color difference between two pixels
double _colorDifference(int color1, int color2) {
  final r1 = (color1 >> 16) & 0xFF;  // Red component of color1
  final g1 = (color1 >> 8) & 0xFF;  // Green component of color1
  final b1 = color1 & 0xFF;  // Blue component of color1
  final r2 = (color2 >> 16) & 0xFF;  // Red component of color2
  final g2 = (color2 >> 8) & 0xFF;  // Green component of color2
  final b2 = color2 & 0xFF;  // Blue component of color2

  // Calculate the Euclidean distance between the two colors in RGB space
  double diff = sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2));  // Distance formula
  return diff;  // Return the calculated color difference
}
