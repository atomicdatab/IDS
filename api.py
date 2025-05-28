from flask import Flask, jsonify, request
from flask_mysqldb import MySQL
from flask_cors import CORS
from functools import wraps
import jwt
from datetime import datetime, timedelta
import html
import re

app = Flask(__name__)
CORS(app)

# Configuration MySQL
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'abdul'
app.config['MYSQL_PASSWORD'] = 'abdul'
app.config['MYSQL_DB'] = 'idsbdd'
app.config['MYSQL_PORT'] = 3307

mysql = MySQL(app)

SECRET_KEY = "votre_clé_secrète"

# Décorateur pour vérifier le token
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({'message': 'Token manquant'}), 401
        try:
            token = token.split()[1]
            
            cur = mysql.connection.cursor()
            cur.execute("""
                SELECT * FROM sessions 
                WHERE token = %s AND expires_at > %s
            """, (token, datetime.utcnow()))
            
            session = cur.fetchone()
            cur.close()
            
            if not session:
                return jsonify({'message': 'Session invalide'}), 401
                
            jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            
        except:
            return jsonify({'message': 'Token invalide'}), 401
            
        return f(*args, **kwargs)
    return decorated

# Route de connexion
# Route de connexion
@app.route('/login', methods=['POST'])
def login():
    try:
        email = request.json.get('email')
        mdp = request.json.get('mdp')

        if not email or not mdp:
            return jsonify({'status': 'error', 'message': 'Email et mot de passe requis'}), 400

        cur = mysql.connection.cursor()
        cur.execute("""
            SELECT u.id, u.email, b.badge_id, b.niveau_acces
            FROM utilisateurs u
            LEFT JOIN badges b ON u.id = b.user_id
            WHERE u.email = %s AND u.mdp = %s
        """, (email, mdp))
        user = cur.fetchone()

        if user:
            token = jwt.encode({
                'user_id': user[0],
                'email': user[1],
                'badge_id': user[2],
                'exp': datetime.utcnow() + timedelta(hours=24)
            }, SECRET_KEY, algorithm="HS256")
            
            # Ajouter l'entrée dans la table des sessions
            cur.execute("""
                INSERT INTO sessions (token, expires_at)
                VALUES (%s, %s)
            """, (
                token,
                datetime.utcnow() + timedelta(hours=24)
            ))
            
            # Ajouter l'entrée dans historique_acces
            cur.execute("""
                INSERT INTO historique_acces (id_utilisateur, date_acces, type_acces)
                VALUES (%s, NOW(), %s)
            """, (user[0], 'Connexion'))
            
            mysql.connection.commit()
            cur.close()
            
            return jsonify({
                'status': 'success',
                'token': token,
                'user': {
                    'email': user[1],
                    'badge_id': user[2],
                    'niveau_acces': user[3]
                },
                'message': 'Connexion réussie'
            }), 200

        cur.close()
        return jsonify({'status': 'error', 'message': 'Identifiants invalides'}), 401

    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

# Route de déconnexion
@app.route('/logout', methods=['POST'])
def logout():
    try:
        token = request.headers.get('Authorization').split()[1]
        cur = mysql.connection.cursor()
        cur.execute("DELETE FROM sessions WHERE token = %s", (token,))
        mysql.connection.commit()
        cur.close()
        return jsonify({'status': 'success', 'message': 'Déconnexion réussie'}), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

# Route d'inscription
@app.route('/register', methods=['POST'])
def register():
    try:
        data = request.json
        required_fields = ['email', 'mdp', 'nom', 'prenom']
        
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'status': 'error',
                    'message': f'Le champ {field} est requis'
                }), 400
        
        # Nettoyage des données entrantes
        safe_email = html.escape(data['email'].strip())
        safe_nom = html.escape(data['nom'].strip())
        safe_prenom = html.escape(data['prenom'].strip())
        password = data['mdp']  # Le mot de passe est géré différemment
        
        # Validation du format de l'email
        email_pattern = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        if not email_pattern.match(safe_email):
            return jsonify({
                'status': 'error',
                'message': 'Format d\'email invalide'
            }), 400
            
        # Validation des autres champs
        if len(safe_nom) < 1 or len(safe_prenom) < 1:
            return jsonify({
                'status': 'error',
                'message': 'Nom et prénom doivent contenir au moins 1 caractère'
            }), 400
            
        if len(password) < 6:
            return jsonify({
                'status': 'error',
                'message': 'Le mot de passe doit contenir au moins 6 caractères'
            }), 400

        cur = mysql.connection.cursor()
        
        # Vérifier si l'email existe déjà
        cur.execute("SELECT email FROM utilisateurs WHERE email = %s", (safe_email,))
        if cur.fetchone():
            return jsonify({
                'status': 'error',
                'message': 'Cet email existe déjà'
            }), 409

        # En production, le mot de passe devrait être haché
        # import hashlib
        # hashed_password = hashlib.sha256(password.encode()).hexdigest()

        # Insérer le nouvel utilisateur
        cur.execute("""
            INSERT INTO utilisateurs (email, mdp, nom, prenom)
            VALUES (%s, %s, %s, %s)
        """, (safe_email, password, safe_nom, safe_prenom))
        
        # Récupérer l'ID de l'utilisateur créé
        user_id = cur.lastrowid
        
        # Générer un badge_id unique
        badge_id = f"BADGE{str(user_id).zfill(3)}"  # Par exemple: BADGE001
        
        # Créer le badge avec niveau d'accès 0
        cur.execute("""
            INSERT INTO badges (user_id, badge_id, niveau_acces)
            VALUES (%s, %s, %s)
        """, (user_id, badge_id, 0))
        
        mysql.connection.commit()
        cur.close()

        return jsonify({
            'status': 'success',
            'message': 'Utilisateur créé avec succès'
        }), 201

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500
# Route pour obtenir tous les utilisateurs
@app.route('/utilisateurs', methods=['GET'])
@token_required
def get_utilisateurs():
    try:
        cur = mysql.connection.cursor()
        cur.execute("""
            SELECT u.id, u.nom, u.prenom, b.badge_id, b.niveau_acces, u.email
            FROM utilisateurs u
            LEFT JOIN badges b ON u.id = b.user_id
        """)
        rows = cur.fetchall()
        cur.close()

        utilisateurs = []
        for row in rows:
            utilisateur = {
                'id': row[0],
                'nom': row[1],
                'prenom': row[2],
                'badge_id': row[3],
                'niveau_acces': row[4],
                'email': row[5]
            }
            utilisateurs.append(utilisateur)

        return jsonify({
            'status': 'success',
            'data': utilisateurs
        }), 200

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# Route pour ajouter un utilisateur
@app.route('/utilisateurs', methods=['POST'])
@token_required
def add_user():
    try:
        data = request.json
        required_fields = ['email', 'mdp', 'nom', 'prenom', 'niveau_acces']
        
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'status': 'error',
                    'message': f'Le champ {field} est requis'
                }), 400

        cur = mysql.connection.cursor()
        
        # Vérifier si l'email existe déjà
        cur.execute("SELECT email FROM utilisateurs WHERE email = %s", (data['email'],))
        if cur.fetchone():
            return jsonify({
                'status': 'error',
                'message': 'Cet email existe déjà'
            }), 409

        # Insérer le nouvel utilisateur
        cur.execute("""
            INSERT INTO utilisateurs (email, mdp, nom, prenom)
            VALUES (%s, %s, %s, %s)
        """, (data['email'], data['mdp'], data['nom'], data['prenom']))
        
        # Récupérer l'ID de l'utilisateur créé
        user_id = cur.lastrowid
        
        # Générer un badge_id unique
        badge_id = f"BADGE{str(user_id).zfill(3)}"  # Par exemple: BADGE001
        
        # Créer le badge avec le niveau d'accès spécifié
        cur.execute("""
            INSERT INTO badges (user_id, badge_id, niveau_acces)
            VALUES (%s, %s, %s)
        """, (user_id, badge_id, data['niveau_acces']))
        
        mysql.connection.commit()
        cur.close()

        return jsonify({
            'status': 'success',
            'message': 'Utilisateur ajouté avec succès',
            'data': {
                'badge_id': badge_id
            }
        }), 201

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# Route pour obtenir un utilisateur spécifique
@app.route('/utilisateurs/<badge_id>', methods=['GET'])
@token_required
def get_user(badge_id):
    try:
        cur = mysql.connection.cursor()
        cur.execute("""
            SELECT u.nom, u.prenom, b.badge_id, b.niveau_acces, u.email
            FROM utilisateurs u
            JOIN badges b ON u.id = b.user_id
            WHERE b.badge_id = %s
        """, (badge_id,))
        
        user = cur.fetchone()
        cur.close()

        if user:
            return jsonify({
                'status': 'success',
                'data': {
                    'nom': user[0],
                    'prenom': user[1],
                    'badge_id': user[2],
                    'niveau_acces': user[3],
                    'email': user[4]
                }
            }), 200
        else:
            return jsonify({
                'status': 'error',
                'message': 'Utilisateur non trouvé'
            }), 404

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# Route pour modifier un utilisateur
@app.route('/utilisateurs/<badge_id>', methods=['PUT'])
@token_required
def update_user(badge_id):
    try:
        data = request.json
        cur = mysql.connection.cursor()

        # Trouver l'ID de l'utilisateur
        cur.execute("""
            SELECT u.id 
            FROM utilisateurs u
            JOIN badges b ON u.id = b.user_id
            WHERE b.badge_id = %s
        """, (badge_id,))
        result = cur.fetchone()
        
        if not result:
            return jsonify({'status': 'error', 'message': 'Utilisateur non trouvé'}), 404
            
        user_id = result[0]

        # Mise à jour de l'utilisateur
        if 'mdp' in data and data['mdp']:
            cur.execute("""
                UPDATE utilisateurs 
                SET nom = %s, prenom = %s, email = %s, mdp = %s
                WHERE id = %s
            """, (data['nom'], data['prenom'], data['email'], data['mdp'], user_id))
        else:
            cur.execute("""
                UPDATE utilisateurs 
                SET nom = %s, prenom = %s, email = %s
                WHERE id = %s
            """, (data['nom'], data['prenom'], data['email'], user_id))

        # Mise à jour du badge
        if 'badge_id' in data and 'niveau_acces' in data:
            cur.execute("""
                UPDATE badges 
                SET badge_id = %s, niveau_acces = %s
                WHERE user_id = %s
            """, (data['badge_id'], data['niveau_acces'], user_id))
        
        mysql.connection.commit()
        cur.close()

        return jsonify({
            'status': 'success',
            'message': 'Utilisateur modifié avec succès'
        }), 200

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/utilisateurs/<badge_id>', methods=['DELETE'])
@token_required
def delete_user(badge_id):
    try:
        cur = mysql.connection.cursor()
        
        # Trouver l'ID de l'utilisateur
        cur.execute("""
            SELECT u.id 
            FROM utilisateurs u
            JOIN badges b ON u.id = b.user_id
            WHERE b.badge_id = %s
        """, (badge_id,))
        result = cur.fetchone()
        
        if not result:
            return jsonify({'status': 'error', 'message': 'Utilisateur non trouvé'}), 404
            
        user_id = result[0]

        # Supprimer d'abord les entrées dans historique_acces
        cur.execute("DELETE FROM historique_acces WHERE id_utilisateur = %s", (user_id,))
        
        # Supprimer le badge
        cur.execute("DELETE FROM badges WHERE user_id = %s", (user_id,))
        
        # Supprimer l'utilisateur
        cur.execute("DELETE FROM utilisateurs WHERE id = %s", (user_id,))
        
        mysql.connection.commit()
        cur.close()

        return jsonify({
            'status': 'success',
            'message': 'Utilisateur supprimé avec succès'
        }), 200

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/alerte', methods=['GET'])
@token_required
def get_alerte():
    try:
        cur = mysql.connection.cursor()
        cur.execute("""
            SELECT ha.id_acces, ha.id_utilisateur, u.nom, u.prenom, b.badge_id, 
                   ha.date_acces, ha.type_acces 
            FROM historique_acces ha
            JOIN utilisateurs u ON ha.id_utilisateur = u.id
            JOIN badges b ON u.id = b.user_id
            ORDER BY ha.date_acces DESC
        """)
        rows = cur.fetchall()
        cur.close()

        alertes = []
        for row in rows:
            # Formater la date côté serveur
            date_acces = row[5]
            date_acces_str = date_acces.strftime("%d/%m/%Y %H:%M:%S")
            
            alerte = {
                'id_acces': row[0],
                'id_utilisateur': row[1],
                'nom': row[2],
                'prenom': row[3],
                'badge_id': row[4],
                'date_acces': date_acces_str,
                'type_acces': row[6]
            }
            alertes.append(alerte)

        return jsonify({
            'status': 'success',
            'data': alertes
        }), 200

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500
# Route pour obtenir l'historique des accès
@app.route('/acces', methods=['GET'])
@token_required
def get_acces():
    try:
        cur = mysql.connection.cursor()
        cur.execute("""
            SELECT ha.id_acces, ha.id_utilisateur, u.nom, u.prenom, b.badge_id, ha.date_acces, ha.type_acces 
            FROM historique_acces ha
            LEFT JOIN utilisateurs u ON ha.id_utilisateur = u.id
            LEFT JOIN badges b ON u.id = b.user_id
            ORDER BY ha.date_acces DESC
        """)
        rows = cur.fetchall()
        cur.close()

        acces = []
        for row in rows:
            acces_item = {
                'id_acces': row[0],
                'nom': row[1],
                'prenom': row[2],
                'badge_id': row[3],
                'date_acces': row[4],
                'type_acces': row[5]
            }
            acces.append(acces_item)

        return jsonify({
            'status': 'success',
            'data': acces
        }), 200

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# Route pour ajouter un nouvel accès
@app.route('/acces', methods=['POST'])
@token_required
def add_acces():
    try:
        data = request.json
        required_fields = ['id_utilisateur', 'type_acces']
        
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'status': 'error',
                    'message': f'Le champ {field} est requis'
                }), 400
        
        cur = mysql.connection.cursor()
        
        # Vérifier si l'utilisateur existe
        cur.execute("SELECT id FROM utilisateurs WHERE id = %s", (data['id_utilisateur'],))
        if not cur.fetchone():
            return jsonify({
                'status': 'error',
                'message': 'Utilisateur non trouvé'
            }), 404
        
        # Insérer le nouvel accès
        cur.execute("""
            INSERT INTO historique_acces (id_utilisateur, date_acces, type_acces)
            VALUES (%s, NOW(), %s)
        """, (data['id_utilisateur'], data['type_acces']))
        
        mysql.connection.commit()
        acces_id = cur.lastrowid
        cur.close()

        return jsonify({
            'status': 'success',
            'message': 'Accès enregistré avec succès',
            'data': {
                'id_acces': acces_id
            }
        }), 201

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)