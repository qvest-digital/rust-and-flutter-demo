class CreateTaskDto {
  final String title;
  final String? description;

  CreateTaskDto({required this.title, this.description});

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };
}
