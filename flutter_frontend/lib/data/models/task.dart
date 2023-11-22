class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime created;
  final bool done;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.created,
    required this.done,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        created: DateTime.parse(json['created']),
        done: json['done'],
      );
}
