from flask import Flask, request, jsonify
from models import db, User, Device
import secrets

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///smart_workspace.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)

with app.app_context():
    db.create_all()


@app.route('/auth/register', methods=['POST'])
def register():
    data = request.json
    if User.query.filter_by(email=data.get('email')).first():
        return jsonify({"error": "User already exists"}), 400
    
    new_user = User(
        full_name=data.get('fullName'),
        email=data.get('email'),
        password=data.get('password'),
        department=data.get('department', 'Unknown')
    )
    db.session.add(new_user)
    db.session.commit()
    return jsonify({"message": "User registered successfully"}), 201

@app.route('/auth/login', methods=['POST'])
def login():
    data = request.json
    user = User.query.filter_by(email=data.get('email'), password=data.get('password')).first()
    
    if user:
        token = secrets.token_hex(20)
        user.access_token = token
        db.session.commit()
        return jsonify({"token": token, "user": user.to_dict()}), 200
        
    return jsonify({"error": "Invalid email or password"}), 401

@app.route('/auth/account', methods=['DELETE'])
def delete_account():
    token = request.headers.get('Authorization')
    user = User.query.filter_by(access_token=token).first()
    if not user:
        return jsonify({"error": "Unauthorized"}), 401
    
    Device.query.filter_by(user_id=user.id).delete()
    db.session.delete(user)
    db.session.commit()
    
    return jsonify({"message": "Account and all devices deleted"}), 200


@app.route('/devices', methods=['GET'])
def get_devices():
    token = request.headers.get('Authorization')
    user = User.query.filter_by(access_token=token).first()
    if not user:
        return jsonify({"error": "Unauthorized"}), 401
    
    devices = Device.query.filter_by(user_id=user.id).all()
    return jsonify([device.to_dict() for device in devices]), 200

@app.route('/devices', methods=['POST'])
def add_device():
    token = request.headers.get('Authorization')
    user = User.query.filter_by(access_token=token).first()
    if not user:
        return jsonify({"error": "Unauthorized"}), 401
    
    data = request.json
    new_device = Device(
        id=data.get('id'), 
        title=data.get('title'),
        value=data.get('value', '--'),
        status=data.get('status', 'Stable'),
        icon_code=data.get('icon_code'),
        color_hex=data.get('color_hex'),
        user_id=user.id 
    )
    db.session.add(new_device)
    db.session.commit()
    return jsonify(new_device.to_dict()), 201

@app.route('/devices/<device_id>', methods=['PUT'])
def update_device(device_id):
    token = request.headers.get('Authorization')
    user = User.query.filter_by(access_token=token).first()
    if not user:
        return jsonify({"error": "Unauthorized"}), 401
    
    device = Device.query.filter_by(id=device_id, user_id=user.id).first()
    if not device:
        return jsonify({"error": "Device not found"}), 404
        
    data = request.json
    device.title = data.get('title', device.title)
    device.value = data.get('value', device.value)
    device.status = data.get('status', device.status)
    device.icon_code = data.get('icon_code', device.icon_code)
    device.color_hex = data.get('color_hex', device.color_hex)
    
    db.session.commit()
    return jsonify(device.to_dict()), 200

@app.route('/devices/<device_id>', methods=['DELETE'])
def delete_device(device_id):
    token = request.headers.get('Authorization')
    user = User.query.filter_by(access_token=token).first()
    if not user:
        return jsonify({"error": "Unauthorized"}), 401
    
    device = Device.query.filter_by(id=device_id, user_id=user.id).first()
    if not device:
        return jsonify({"error": "Device not found"}), 404
        
    db.session.delete(device)
    db.session.commit()
    return jsonify({"message": "Device deleted"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

