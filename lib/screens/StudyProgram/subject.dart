class Subject {
  const Subject(
      {required this.name,
      this.tp = false,
      required this.grade,
      required this.id,
      required this.correlatives});
  final String name;
  final bool tp;
  final int grade;
  final int id;
  final List<int> correlatives;
}
