class StatsModel {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;
  final int closed;
  final int delivered;
  final double totalRevenue;
  final double balancePending;

  StatsModel({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.closed,
    required this.delivered,
    required this.totalRevenue,
    required this.balancePending,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      inProgress: json['inProgress'] ?? 0,
      completed: json['completed'] ?? 0,
      closed: json['closed'] ?? 0,
      delivered: json['delivered'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      balancePending: (json['balancePending'] ?? 0).toDouble(),
    );
  }

  factory StatsModel.empty() {
    return StatsModel(
      total: 0,
      pending: 0,
      inProgress: 0,
      completed: 0,
      closed: 0,
      delivered: 0,
      totalRevenue: 0.0,
      balancePending: 0.0,
    );
  }
}
