class PhotoSession {
  final int gridCount;
  final int rows;
  final int cols;

  PhotoSession({required this.gridCount}) 
    : rows = gridCount == 1 ? 1 : (gridCount == 4 ? 2 : 3),
      cols = gridCount == 1 ? 1 : (gridCount == 4 ? 2 : 3);
}