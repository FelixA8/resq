
import 'package:resqapp/services/supabase_service.dart';
import 'package:resqapp/models/supabase_models.dart';

class LoginService {
  Future<ResponseTeam?> responseTeamLogin(String instanceCode, String password) async {
    try {
      final user = await SupabaseService.loginResponseTeam(instanceCode, password);

      if (user == null) {
        return null;
      }
            
      return user;
    } catch (e) {
      print('Error in loginResponseTeamByUserId: $e');
      return null;
    }
  }
}