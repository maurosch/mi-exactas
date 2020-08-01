class Subject
{
  const Subject({this.name, this.tp = false, this.grade, this.id, this.correlatives});
  final String name;
  final bool tp;
  final int grade;
  final int id;
  final List<int> correlatives;
}