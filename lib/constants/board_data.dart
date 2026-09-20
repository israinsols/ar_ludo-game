class BoardData {
  static const int boardSize = 15;
  static const int mainPathLength = 52;
  static const int homeColumnLength = 5;

  // Clockwise main path (standard Ludo)
  static const List<List<int>> mainPath = [
    [0, 6],   // 0
    [0, 7],   // 1
    [0, 8],   // 2
    [1, 8],   // 3
    [2, 8],   // 4
    [3, 8],   // 5
    [4, 8],   // 6
    [5, 8],   // 7
    [6, 9],   // 8
    [6, 10],  // 9
    [6, 11],  // 10
    [6, 12],  // 11
    [6, 13],  // 12
    [6, 14],  // 13
    [7, 14],  // 14
    [8, 14],  // 15
    [8, 13],  // 16
    [8, 12],  // 17
    [8, 11],  // 18
    [8, 10],  // 19
    [8, 9],   // 20
    [9, 8],   // 21
    [10, 8],  // 22
    [11, 8],  // 23
    [12, 8],  // 24
    [13, 8],  // 25
    [14, 8],  // 26
    [14, 7],  // 27
    [14, 6],  // 28
    [13, 6],  // 29
    [12, 6],  // 30
    [11, 6],  // 31
    [10, 6],  // 32
    [9, 6],   // 33
    [8, 5],   // 34
    [8, 4],   // 35
    [8, 3],   // 36
    [8, 2],   // 37
    [8, 1],   // 38
    [8, 0],   // 39
    [7, 0],   // 40
    [6, 0],   // 41
    [6, 1],   // 42
    [6, 2],   // 43
    [6, 3],   // 44
    [6, 4],   // 45
    [6, 5],   // 46
    [5, 6],   // 47
    [4, 6],   // 48
    [3, 6],   // 49
    [2, 6],   // 50
    [1, 6],   // 51
  ];

  static const List<int> safePositions = [11, 24, 37, 50, 42, 3, 29, 16];

  // Home columns (toward center)
  // Index 0: Red (left) -> row 7, cols 1-5 (going right)
  // Index 1: Blue (top) -> col 7, rows 1-5 (going down)
  // Index 2: Green (bottom) -> col 7, rows 13-9 (going up)
  // Index 3: Yellow (right) -> row 7, cols 13-9 (going left)
  static const List<List<List<int>>> homeColumns = [
    [[7,1],[7,2],[7,3],[7,4],[7,5]],     // Red - left
    [[1,7],[2,7],[3,7],[4,7],[5,7]],     // Blue - top
    [[13,7],[12,7],[11,7],[10,7],[9,7]], // Green - bottom
    [[7,13],[7,12],[7,11],[7,10],[7,9]], // Yellow - right
  ];

  // Base positions (gap 0.8)
  // Red - top-left (base center = [2.5, 2.5])
  static const List<List<double>> redBase = [
    [2.1, 2.1], [2.1, 2.9], [2.9, 2.1], [2.9, 2.9]
  ];
  // Blue - top-right (base center = [2.5, 11.5])
  static const List<List<double>> blueBase = [
    [2.1, 11.1], [2.1, 11.9], [2.9, 11.1], [2.9, 11.9]
  ];
  // Green - bottom-left (base center = [11.5, 2.5])
  static const List<List<double>> greenBase = [
    [11.1, 2.1], [11.1, 2.9], [11.9, 2.1], [11.9, 2.9]
  ];
  // Yellow - bottom-right (base center = [11.5, 11.5])
  static const List<List<double>> yellowBase = [
    [11.1, 11.1], [11.1, 11.9], [11.9, 11.1], [11.9, 11.9]
  ];

  static int getDistanceFromStart(int currentIndex, int startIndex) {
    return (currentIndex - startIndex + mainPathLength) % mainPathLength;
  }

  static int getPositionAtDistance(int startIndex, int distance) {
    return (startIndex + distance) % mainPathLength;
  }

  static bool isSafePosition(int pathIndex) {
    return safePositions.contains(pathIndex);
  }
}
