import 'package:flutter/material.dart';

class ContourResult {
  List<Offset> contour; // Ordered contour points
  List<Offset> leftover; // Unused points

  ContourResult(this.contour, this.leftover);
}

ContourResult mooreNeighborTracingWithTolerance(List<Offset> points, double tolerance) {
  // Convert points into a Set for fast lookup
  final pointSet = points.toSet();

  // Find the starting point (lowest y, then lowest x)
  Offset startPoint = points.reduce((a, b) =>
      (a.dy < b.dy || (a.dy == b.dy && a.dx < b.dx)) ? a : b);

  // Define directions for 8-connectivity
  final directions = [
    const Offset(0, -1),  // N
    const Offset(1, -1),  // NE
    const Offset(1, 0),   // E
    const Offset(1, 1),   // SE
    const Offset(0, 1),   // S
    const Offset(-1, 1),  // SW
    const Offset(-1, 0),  // W
    const Offset(-1, -1), // NW
  ];

  List<Offset> contour = [];
  Offset current = startPoint;
  Offset previous = startPoint + const Offset(-1, 0); // Start with a fake "previous"

  Set<Offset> visited = {startPoint};

  do {
    contour.add(current);

    // Find the direction from the previous point to the current
    int startDir = directions.indexWhere(
        (dir) => (current + dir) == previous);

    bool foundNeighbor = false;

    // Start checking neighbors in a clockwise order
    for (int i = 0; i < directions.length; i++) {
      int dirIndex = (startDir + i) % directions.length;
      Offset neighbor = current + directions[dirIndex];

      // Check if the neighbor is valid, within tolerance, and not already visited
      if (pointSet.contains(neighbor) &&
          !visited.contains(neighbor) &&
          (neighbor - current).distance <= tolerance) {

        visited.add(neighbor);
        previous = current; // Update previous
        current = neighbor; // Move to the neighbor
        foundNeighbor = true;
        break;
      }
    }

    // If no valid neighbor is found, exit loop
    if (!foundNeighbor) {
      break;
    }

  } while (current != startPoint); // Stop when back to start

  // Identify leftover points (points not in the visited set)
  List<Offset> leftover = points.where((point) => !visited.contains(point)).toList();

  return ContourResult(contour, leftover);

}
