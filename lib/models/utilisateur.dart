class Utilisateur {
  int idUtilisateur;
  String nomUtilisateur;
  String email;
  String motPasse;
  int age;
  String sexe;
  int cliqueCable;

  Utilisateur({
    required this.idUtilisateur,
    required this.nomUtilisateur,
    required this.email,
    required this.motPasse,
    required this.age,
    required this.sexe,
    required this.cliqueCable,
  });

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id_utilisateur': idUtilisateur,
      'nom_utilisateur': nomUtilisateur,
      'email': email,
      'mot_passe': motPasse,
      'age': age,
      'sexe': sexe,
      'clique_cable': cliqueCable,
    };
  }

  // Create a Utilisateur object from JSON response
  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      idUtilisateur: json['id_utilisateur'],
      nomUtilisateur: json['nom_utilisateur'],
      email: json['email'],
      motPasse: json['mot_passe'],
      age: json['age'],
      sexe: json['sexe'],
      cliqueCable: json['clique_cable'],
    );
  }
}
