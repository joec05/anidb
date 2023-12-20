class UserMangaStatisticsClass{
  int reading;
  int completed;
  int onHold;
  int dropped;
  int planToRead;
  int total;
  double daysRead;
  int totalVolumes;
  int totalChapters;
  int reread;
  int totalScore;
  int ratedCount;
  double meanScore;

  UserMangaStatisticsClass(
    this.reading,
    this.completed,
    this.onHold,
    this.dropped,
    this.planToRead,
    this.total,
    this.daysRead,
    this.totalVolumes,
    this.totalChapters,
    this.reread,
    this.totalScore,
    this.ratedCount,
    this.meanScore
  );

  factory UserMangaStatisticsClass.generateNewInstance(){
    return UserMangaStatisticsClass(
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    );
  }
}