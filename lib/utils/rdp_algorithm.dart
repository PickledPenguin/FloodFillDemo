import 'dart:math';
import 'package:flutter/material.dart';
import './contour.dart';

// Function to calculate the perpendicular distance from a point to a line segment
double perpendicularDistance(Offset point, Offset lineStart, Offset lineEnd) {
  double numerator = (lineEnd.dy - lineStart.dy) * point.dx -
      (lineEnd.dx - lineStart.dx) * point.dy +
      lineEnd.dx * lineStart.dy - lineEnd.dy * lineStart.dx;
  double denominator = sqrt(pow(lineEnd.dy - lineStart.dy, 2) +
      pow(lineEnd.dx - lineStart.dx, 2));
  return numerator.abs() / denominator;
}

// RDP (Ramer Douglas Peucker) Algorithm: Simplifies a set of points into a smaller set based on tolerance
List<Offset> rdp(List<Offset> points, int start, int end, double tolerance) {
  int index = -1;
  double maxDist = 0.0;

  // Find the point that is farthest from the line between start and end
  for (int i = start + 1; i < end; i++) {
    double dist = perpendicularDistance(points[i], points[start], points[end]);
    if (dist > maxDist) {
      maxDist = dist;
      index = i;
    }
  }

  // If the maximum distance is greater than the tolerance, split the path at the index
  if (maxDist > tolerance) {
    List<Offset> firstHalf = rdp(points, start, index, tolerance);
    List<Offset> secondHalf = rdp(points, index, end, tolerance);
    firstHalf.removeLast(); // Remove the duplicate point
    return firstHalf + secondHalf;
  } else {
    // If the distance is within tolerance, just return the endpoints
    return [points[start], points[end]];
  }
}

// Function to simplify the polyline using RDP algorithm
List<Offset> simplifyPolyline(List<Offset> points, double tolerance) {
  if (points.length <= 4) {
    return points; // No simplification needed if there are <= four points (Not sure why this would ever be the case but just in case we recurse the algorithm)
  }

  // First sort the points using the mooreNeighborTracingWithTolerance function
  double contourTolerance = 10.0;

  // Call the contour tracing function
  ContourResult result = mooreNeighborTracingWithTolerance(points, contourTolerance);

  // Access ordered contour and leftover points
  List<Offset> contour = result.contour;

  print("contour:");
  print(contour);

  // This is the leftovers, which will be useful for auto-calculating obstacles later
  List<Offset> leftover = result.leftover;

  print("leftover:");
  print(leftover);

  // Start simplification from the first to the last point
  return rdp(contour, 0, contour.length - 1, tolerance);
}
