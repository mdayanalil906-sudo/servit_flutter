Map<String, String> categoryIcons = {
  'Plumbing': '🔧',
  'Electrical': '⚡',
  'Carpentry': '🪚',
  'Cleaning': '🧹',
  'Painting': '🎨',
  'AC Service': '❄️',
  'Appliance Repair': '🔌',
  'Plumber': '🔧',
  'Electrician': '⚡',
  'Carpenter': '🪚',
  'Cleaner': '🧹',
  'Painter': '🎨',
  'AC Technician': '❄️',
};

String getCategoryIcon(String name) {
  return categoryIcons[name] ?? '🛠️';
}

Map<String, IconData> get iconMap {
  return {};
}
