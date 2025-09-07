class SmsMessage {
  final String id;
  final String sender;
  final String body;
  final DateTime timestamp;
  final String? address;

  SmsMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.timestamp,
    this.address,
  });

  factory SmsMessage.fromJson(Map<String, dynamic> json) {
    return SmsMessage(
      id: json['id'] ?? '',
      sender: json['sender'] ?? '',
      body: json['body'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'body': body,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'address': address,
    };
  }

  bool get isMobileMoneyTransaction {
    final mobileMoneySenders = [
      'MTN',
      'VODAFONE',
      'AIRTELTIGO',
      'TELECEL',
      'MOMO',
      'MOBILE',
      'MONEY',
    ];

    final bodyLower = body.toLowerCase();
    final senderUpper = sender.toUpperCase();

    return mobileMoneySenders.any(
          (sender) =>
              senderUpper.contains(sender) ||
              bodyLower.contains(sender.toLowerCase()),
        ) ||
        _containsTransactionKeywords();
  }

  bool _containsTransactionKeywords() {
    final keywords = [
      'transaction',
      'transfer',
      'payment',
      'balance',
      'received',
      'sent',
      'withdraw',
      'deposit',
      'cedis',
      'ghs',
      'amount',
      'ref:',
      'reference',
    ];

    final bodyLower = body.toLowerCase();
    return keywords.any((keyword) => bodyLower.contains(keyword));
  }

  @override
  String toString() {
    return 'SmsMessage(id: $id, sender: $sender, body: $body, timestamp: $timestamp)';
  }
}
