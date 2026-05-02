class PhotoSession {
  final int gridCount;
  final int rows;
  final int cols;
  final String backgroundCategory;
  final bool useFrontCamera;

  PhotoSession({
    required this.gridCount,
    this.backgroundCategory = 'solid',
    this.useFrontCamera = false,
  }) 
    : rows = gridCount == 1 ? 1 : (gridCount == 4 ? 2 : (gridCount == 6 ? 2 : (gridCount == 8 ? 2 : (gridCount == 10 ? 2 : (gridCount == 12 ? 2 : 3))))),
      cols = gridCount == 1 ? 1 : (gridCount == 4 ? 2 : (gridCount == 6 ? 3 : (gridCount == 8 ? 4 : (gridCount == 10 ? 5 : (gridCount == 12 ? 6 : 3)))));
}