class BoxDimensions {
  final double height;
  final double length;
  final double width;

  BoxDimensions({
    required this.height,
    required this.length,
    required this.width,
  });

  double get volume => height * length * width;
}
