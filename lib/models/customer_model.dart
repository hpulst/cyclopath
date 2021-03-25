class Customer {
  Customer({
    required this.id,
    required this.forename,
    required this.name,
    required this.adress,
    required this.email,
    required this.phone,
    this.company,
  });
  final int id;
  final String forename;
  final String name;
  final String adress;
  final String email;
  final String phone;
  final String? company;
}
