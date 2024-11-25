import 'dart:typed_data';  // For handling image byte data
import 'package:flutter/material.dart';  // Flutter material design components
import 'package:image_picker/image_picker.dart';  // For picking images from gallery
import 'package:image/image.dart' as img;  // For image manipulation
import '../utils/selection_fill.dart';  // Selection and fill logic
import '../widgets/outline_painter.dart';  // Custom painter to draw the outline
import '../utils/rdp_algorithm.dart';

// StatefulWidget for selecting and processing the image
class ImageSelectorScreen extends StatefulWidget {
  const ImageSelectorScreen({super.key});

  @override
  State<ImageSelectorScreen> createState() => _ImageSelectorScreenState();
}

class _ImageSelectorScreenState extends State<ImageSelectorScreen> {
  // Variables to hold the selected image data and outline points
  Uint8List? _imageBytes;  // Image bytes (used to display the image)
  img.Image? _selectedImage;  // Decoded image for processing
  List<Offset> _outlinePoints = [];  // Points that define the outline of a region
  final ImagePicker _picker = ImagePicker();  // Image picker instance

  // Variables for controlling the outline process
  double _tolerance = 30.0;  // Base tolerance for color difference in outline detection
  double _imageWidth = 0;  // Width of the image on screen
  double _imageHeight = 0;  // Height of the image on screen
  Offset? _tapPosition;  // Position where the user tapped on the image
  List<Offset> _polylinePoints = []; // For polylines
  double _polylineTolerance = 70.0;  // For polyline tolerance
  bool _showRedOutline = false;

  // Variables to control Advanced Settings
  Map<String,double> _polylineToleranceMinMax = {"min": 0.1, "max": 100.0};

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    // Open the image picker to select an image from the gallery
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();  // Read the file bytes
      setState(() {
        _imageBytes = bytes;  // Store the image bytes
        _selectedImage = img.decodeImage(bytes);  // Decode image for manipulation
      });
    }
  }

  // Method to handle when the user taps on the image
  void _onTapDown(TapDownDetails details) {
    if (_selectedImage != null) {
      final Offset pos = details.localPosition;  // Get the position of the tap

      // Adjust tap position based on image scale
      double scaleX = _selectedImage!.width / _imageWidth;
      double scaleY = _selectedImage!.height / _imageHeight;
      final int x = (pos.dx * scaleX).toInt();
      final int y = (pos.dy * scaleY).toInt();

      if (x >= 0 && x < _selectedImage!.width && y >= 0 && y < _selectedImage!.height) {
        setState(() {
          _tapPosition = Offset(x.toDouble(), y.toDouble());  // Update tap position
        });
        _updateDrawings();  // Trigger outline drawing based on tap position
      }
    }
  }

  void _updateDrawings(){
    _drawOutline();
    _generatePolyline();
  }

  // Method to draw the outline around the selected region
  void _drawOutline() {
    if (_selectedImage != null && _tapPosition != null) {
      final int x = _tapPosition!.dx.toInt();
      final int y = _tapPosition!.dy.toInt();
      final outlinePoints = getOutline(_selectedImage!, x, y, _tolerance);

      setState(() {
        _outlinePoints = outlinePoints; // Update the list of outline points
      });
    }
  }


  // Method to filter out smaller clusters of points from the outline points
  List<Offset> filterClusters(List<Offset> points, {int minSize = 20}) {
    List<List<Offset>> clusters = [];
    Set<Offset> visited = {};  // Track visited points to avoid duplicates

    // Loop through all points and perform depth-first search (DFS) for clustering
    for (Offset point in points) {
      if (visited.contains(point)) continue;

      List<Offset> cluster = [];
      _dfsCluster(points, point, cluster, visited);  // Find all connected points in the cluster
      if (cluster.length >= minSize) {
        clusters.add(cluster);  // Only add clusters of sufficient size
      }
    }

    // Flatten the list of clusters and return all points
    return clusters.expand((cluster) => cluster).toList();
  }

  // Depth-first search (DFS) to find all points connected to the start point
  void _dfsCluster(List<Offset> points, Offset start, List<Offset> cluster, Set<Offset> visited) {
    List<Offset> stack = [start];  // Stack to keep track of points to explore
    visited.add(start);

    // Explore all neighboring points
    while (stack.isNotEmpty) {
      Offset current = stack.removeLast();  // Get the next point to explore
      cluster.add(current);  // Add it to the current cluster

      // Check neighboring points
      for (Offset neighbor in points) {
        if (!visited.contains(neighbor) && (neighbor - current).distance < 5.0) {
          visited.add(neighbor);  // Mark the neighbor as visited
          stack.add(neighbor);  // Add the neighbor to the stack for further exploration
        }
      }
    }
  }

  void _generatePolyline() {
    setState(() {
      // Use the RDP algorithm to simplify the outline points

      double polylineToleranceAdjusted = _polylineToleranceMinMax["max"]! - _polylineTolerance;

      List<Offset> simplifiedPoints = simplifyPolyline(_outlinePoints, polylineToleranceAdjusted);
      
      // Scale the polyline points to match the image size
      _polylinePoints = simplifiedPoints.map((point) {
        return Offset(point.dx, point.dy);
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Selector Tool'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display the selected image with outline drawing
            if (_imageBytes != null)
              GestureDetector(
                onTapDown: _onTapDown, // Handle taps on the image
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double imageWidth = constraints.maxWidth;
                    double imageHeight = (_selectedImage != null)
                        ? (imageWidth * _selectedImage!.height) / _selectedImage!.width
                        : 0.0;

                    // Store the current image dimensions
                    _imageWidth = imageWidth;
                    _imageHeight = imageHeight;

                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: imageHeight,
                      ),
                      child: Center(
                        child: Stack(
                          children: [
                            // Display the image
                            Image.memory(
                              _imageBytes!,
                              width: imageWidth,
                              height: imageHeight,
                            ),
                            // Draw the outline on top of the image using a custom painter
                            if (_outlinePoints.isNotEmpty)
                              CustomPaint(
                                painter: OutlinePainter(
                                  _outlinePoints,
                                  scaleX: _imageWidth / _selectedImage!.width,
                                  scaleY: _imageHeight / _selectedImage!.height,
                                  tapPosition: _tapPosition,
                                  showRedOutline: _showRedOutline
                                ),
                                size: Size(imageWidth, imageHeight),
                              ),
                            // Draw the polyline if available
                            if (_polylinePoints.isNotEmpty)
                              CustomPaint(
                                painter: PolylinePainter(
                                  _polylinePoints,
                                  scaleX: _imageWidth / _selectedImage!.width,
                                  scaleY: _imageHeight / _selectedImage!.height,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),

            // Button to pick an image
            Row (
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child:
                      FloatingActionButton(
                        onPressed: _pickImage,
                        tooltip: "Pick Image",
                        child: const Icon(Icons.image),
                      ),
                    ),
                ),
              ]
            ),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible (
                  flex: 5,
                  child:
                    Center(
                      child:
                        Column(
                          children: [// Tolerance slider for outline calculation
                            Text('Tolerance: ${_tolerance.toInt()}%'),
                            Slider(
                              min: 0,
                              max: 100,
                              divisions: 100,
                              value: _tolerance,
                              label: '${_tolerance.toInt()}%',
                              onChanged: (value) {
                                setState(() {
                                  _tolerance = value; // Update tolerance
                                });
                              },
                            ),
                          ]
                        ),
                    ),
                ),

                // Button to apply the outline with the selected tolerance
                FloatingActionButton(
                  onPressed: _updateDrawings,
                  tooltip: 'Apply Tolerance', // Optional tooltip
                  child: const Icon(Icons.palette), // Use a checkmark icon
                ),

                // Add a spacer to create some distance
                const Spacer(flex: 1),
              ]
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:[
                Flexible (
                  flex: 5,
                  child:
                    Center(
                      child:
                        Column(
                          children: [
                            // New Slider for adjusting polyline complexity
                            const Text('Polyline Complexity: '),
                            Slider(
                              min: _polylineToleranceMinMax["min"]!,
                              max: _polylineToleranceMinMax["max"]!,
                              divisions: 99,
                              value: _polylineTolerance,
                              onChanged: (value) {
                                setState(() {
                                  _polylineTolerance = value; // Update polyline tolerance in inverse (more complex = less tolerance)
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                          ]
                        ),
                    ),
                ),

                // Button to generate the polyline based on the current tolerance
                FloatingActionButton(
                  onPressed: _updateDrawings,
                  tooltip: 'Generate Polylines', // Optional tooltip
                  child: const Icon(Icons.polyline), // Use a polyline icon
                ),

                // Add a spacer to create some distance
                const Spacer(flex: 1),

              ]
            ),

            const SizedBox(height: 20),

            // Checkbox to toggle red outline visibility
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Show Edge Detection'),
                Checkbox(
                  value: _showRedOutline,
                  onChanged: (bool? value) {
                    setState(() {
                      _showRedOutline = value ?? true; // Update checkbox state
                    });
                  },
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }



}
