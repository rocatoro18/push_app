// ENTIDAD PARA HACER UN MAPEO Y VER FACILMENTE COMO LUCE LA DATA
class PushMessage {
  final String messageId;
  final String title;
  final String body;
  final DateTime sendDate;
  final Map<String, dynamic>? data;
  final String? imageUrl;

  PushMessage(
      {required this.messageId,
      required this.title,
      required this.body,
      required this.sendDate,
      this.data,
      this.imageUrl});

  @override
  String toString() {
    return '''
  PushMessage -
  id:       $messageId
  title:    $title
  body:     $body
  sentDate: $sendDate
  data:     $data
  imageUrl: $imageUrl
  ''';
  }
}
