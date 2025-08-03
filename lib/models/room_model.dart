class Room {
  final String? id;
  final String name;
  final String image;
  final String price;
  final String roomTypeId;
  final String rate;
  final String location;
  final bool isFavorited;
  final bool isBooked;
  final List<String> albumImages;
  final String description;

  Room({
    this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.roomTypeId,
    required this.rate,
    required this.location,
    required this.isFavorited,
    required this.isBooked,
    required this.albumImages,
    required this.description,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: json['price']?.toString() ?? '',
      roomTypeId: json['roomTypeId'] ?? '',
      rate: json['rate']?.toString() ?? '',
      location: json['location'] ?? '',
      isFavorited: json['is_favorited'] ?? false,
      isBooked: json['isBooked'] ?? false,
      albumImages: json['album_images'] != null
          ? List<String>.from(json['album_images'])
          : <String>[],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'roomTypeId': roomTypeId,
      'rate': rate,
      'location': location,
      'is_favorited': isFavorited,
      'isBooked': isBooked,
      'album_images': albumImages,
      'description': description,
    };
  }

  Room copyWith({
    String? id,
    String? name,
    String? image,
    String? price,
    String? roomTypeId,
    String? rate,
    String? location,
    bool? isFavorited,
    bool? isBooked,
    List<String>? albumImages,
    String? description,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      roomTypeId: roomTypeId ?? this.roomTypeId,
      rate: rate ?? this.rate,
      location: location ?? this.location,
      isFavorited: isFavorited ?? this.isFavorited,
      isBooked: isBooked ?? this.isBooked,
      albumImages: albumImages ?? this.albumImages,
      description: description ?? this.description,
    );
  }
}
