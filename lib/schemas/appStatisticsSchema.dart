class AppStatisticsSchecma {
  int usersCount;
  int usersLogOutCount;
  int autoSigninCount;
  int activitiesCount;
  int shareAppCount;
  int editedActivitiesCount;
  String year;
  int createdAt;

  AppStatisticsSchecma({
    required this.usersCount,
    required this.usersLogOutCount,
    required this.createdAt,
    required this.year,
    required this.autoSigninCount,
    required this.activitiesCount,
    required this.editedActivitiesCount,
    required this.shareAppCount,
  });

  static AppStatisticsSchecma toSchema(var data) {
    return AppStatisticsSchecma(
      usersCount: data["usersCount"],
      usersLogOutCount: data["usersLogOutCount"],
      createdAt: data["createdAt"],
      year: data["year"],
      autoSigninCount: data["autoSigninCount"],
      activitiesCount: data["activitiesCount"],
      editedActivitiesCount: data["editedActivitiesCount"],
      shareAppCount: data["shareAppCount"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "usersCount": usersCount,
      "shareAppCount": shareAppCount,
      "createdAt": createdAt,
      "usersLogOutCount": usersLogOutCount,
      "autoSigninCount": autoSigninCount,
      "activitiesCount": activitiesCount,
      "editedActivitiesCount": "editedActivitiesCount",
      "year": year,
    };
  }
}
