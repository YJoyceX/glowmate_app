class Product {
  final String productid;
  final String productname;
  final String brand;
  final String image_url;
  final String skintype;
  final String skinconcerns;
  final String producttype;
  final String ingredients;
  final String day_night;

  Product({
    required this.productid,
    required this.productname,
    required this.brand,
    required this.image_url,
    required this.skintype,
    required this.skinconcerns,
    required this.producttype,
    required this.ingredients,
    required this.day_night,
  });

  // --- 1. FACTORY FOR SUPABASE (The Main One) ---
  // This converts the JSON/Map from Supabase into a Product object.
  // Note: We use the exact column names from your SQL table here.
  factory Product.fromSupabase(Map<String, dynamic> data) {
    return Product(
      productid: data['id']?.toString() ?? '',
      productname: data['productname'] ?? '',
      brand: data['brand'] ?? '',
      // Map 'skintype' column to skinType property
      skintype: data['skintype'] ?? 'All', 
      // Map 'skinconcerns' column to concern property
      skinconcerns: data['skinconcerns'] ?? '', 
      producttype: data['producttype'] ?? '',
      ingredients: data['ingredients'] ?? '',
      day_night: data['day_night'] ?? 'day|night',
      // Map 'image_url' column (which holds the asset path) to imageUrl
      image_url: data['image_url'] ?? 'assets/images/SkincareProducts.png', 
    );
  }

  // --- 2. FACTORY FOR CSV (Optional Backup) ---
  // You can keep this if you ever need to load from the file again, 
  // but the app now uses the Supabase one above.
  factory Product.fromCsv(List<dynamic> row) {
    return Product(
      productid: row[0].toString(),
      productname: row[1].toString(),
      brand: row[2].toString(),
      skintype: row[3].toString(),
      skinconcerns: row[4].toString(),
      producttype: row[5].toString(),
      ingredients: row[6].toString(),
      day_night: row[7].toString(),
      image_url: row[8].toString(),
    );
  }
}