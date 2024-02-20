class UserAnimeStatisticsClass{
  int watching;
  int completed;
  int onHold;
  int dropped;
  int planToWatch;
  int total;
  double daysWatched;
  int totalEpisodes;
  int rewatched;
  int totalScore;
  int ratedCount;
  double meanScore;

  UserAnimeStatisticsClass(
    this.watching,
    this.completed,
    this.onHold,
    this.dropped,
    this.planToWatch,
    this.total,
    this.daysWatched,
    this.totalEpisodes,
    this.rewatched,
    this.totalScore,
    this.ratedCount,
    this.meanScore
  );

  factory UserAnimeStatisticsClass.generateNewInstance(){
    return UserAnimeStatisticsClass(
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    );
  }

  UserAnimeStatisticsClass copy() {
    return UserAnimeStatisticsClass(
      watching, completed, onHold, dropped, planToWatch, total, 
      daysWatched, totalEpisodes, rewatched, totalScore, ratedCount, 
      meanScore
    );
  }
}