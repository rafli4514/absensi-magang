class LogBook {
  final String id;
  final String title; // Kegiatan utama
  final String content; // Detail keterangan
  final String location; // Lokasi (mis: Lapangan, Kantor, Site A)
  final String mentorName; // Nama Mentor pendamping
  final DateTime createdAt;

  LogBook({
    required this.id,
    required this.title,
    required this.content,
    required this.location,
    required this.mentorName,
    required this.createdAt,
  });

  // Helper untuk clone data saat edit (optional tapi berguna)
  LogBook copyWith({
    String? title,
    String? content,
    String? location,
    String? mentorName,
  }) {
    return LogBook(
      id: this.id,
      createdAt: this.createdAt,
      title: title ?? this.title,
      content: content ?? this.content,
      location: location ?? this.location,
      mentorName: mentorName ?? this.mentorName,
    );
  }
}
