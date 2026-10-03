class MasterValidation {
  // Category Name: Alphanumeric, Special characters like - ( ) [ ] * &
  static String? validateCategoryName(String? value) {
    if (value == null || value.isEmpty) return "Required";
    final regex = RegExp(r"^[a-zA-Z0-9\s\-\(\)\[\]\*\&]+$");
    if (!regex.hasMatch(value)) return "Invalid characters used";
    return null;
  }

  // Remarks General: Allow alphanumerics, Special characters like . , / \ ‘’ “” : ; ( ) # % & _ - *
  static String? validateRemarks(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r"^[a-zA-Z0-9\s\.\,\/\\\‘\’\“\”\:\;\(\)\#\%\&\_\-\*]+$");
    if (!regex.hasMatch(value)) return "Invalid characters in remarks";
    return null;
  }

  // Brand Name: Alphanumerics, Special characters like . , / \ ‘’ “” : ; ( ) # % & _ - * @
  static String? validateBrandName(String? value) {
    if (value == null || value.isEmpty) return "Required";
    final regex = RegExp(r"^[a-zA-Z0-9\s\.\,\/\\\‘\’\“\”\:\;\(\)\#\%\&\_\-\*\@]+$");
    if (!regex.hasMatch(value)) return "Invalid characters in brand name";
    return null;
  }

  // Item Name: Alphanumerics, special characters like - ( )
  static String? validateItemName(String? value) {
    if (value == null || value.isEmpty) return "Required";
    final regex = RegExp(r"^[a-zA-Z0-9\s\-\(\)]+$");
    if (!regex.hasMatch(value)) return "Invalid characters in item name";
    return null;
  }
}
