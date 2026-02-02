class API {
  static const String base_url = 'https://roombooking-backend-l7kv.onrender.com';
  static const String loginUser = '/auth/login';
  static const String registerUser = '/auth/register';
  static const String getBookings = '/bookings/me';
  static const String createBooking = '/bookings';
  static const String updateBooking = '/bookings';
  static const String deleteBooking = '/bookings';
  static const String checkInBooking = '/bookings/checkin';
  static const String getBuildings = '/buildings';
  static const String getRooms = '/rooms';
  static const String adminRooms = '/admin/rooms';
  static const String getRoomEquipment = '/rooms/equipment';
  static const String adminStats = "/admin/stats";
  static const String adminUsers = "/admin/users";
  static const String adminCancelBooking = "/admin/bookings";
}