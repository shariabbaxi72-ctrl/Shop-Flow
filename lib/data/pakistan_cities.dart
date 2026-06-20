class PakistanCities {
  static const List<String> cities = [
    'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Faisalabad',
    'Multan', 'Peshawar', 'Quetta', 'Sialkot', 'Gujranwala',
    'Hyderabad', 'Bahawalpur', 'Sargodha', 'Sukkur', 'Larkana',
    'Sheikhupura', 'Rahimyar Khan', 'Jhang', 'Dera Ghazi Khan',
    'Gujrat', 'Sahiwal', 'Wah Cantt', 'Mardan', 'Kasur',
    'Okara', 'Mingora', 'Nawabshah', 'Chiniot', 'Kotri',
    'Abbottabad', 'Mirpur', 'Muzaffarabad', 'Gilgit', 'Turbat',
    'Khuzdar', 'Chaman', 'Jacobabad', 'Shikarpur', 'Khairpur',
    'Dadu', 'Nowshera', 'Kohat', 'Bannu', 'Dera Ismail Khan',
    'Swabi', 'Chakwal', 'Jhelum', 'Attock', 'Hafizabad',
    'Mianwali', 'Bhakkar', 'Khanewal', 'Pakpattan', 'Vehari',
    'Lodhran', 'Muzaffargarh', 'Layyah', 'Toba Tek Singh',
  ];

  static List<String> search(String query) {
    if (query.isEmpty) return cities;
    return cities
        .where((c) =>
        c.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}