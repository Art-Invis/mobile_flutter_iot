from flask_sqlalchemy import SQLAlchemy
import uuid

db = SQLAlchemy()

class User(db.Model):
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    full_name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    department = db.Column(db.String(100))
    access_token = db.Column(db.String(100), unique=True) 

    def to_dict(self):
        return {
            "id": self.id,
            "fullName": self.full_name,
            "email": self.email,
            "department": self.department
        }

class Device(db.Model):
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title = db.Column(db.String(100), nullable=False)
    value = db.Column(db.String(50))
    status = db.Column(db.String(50), default="Stable")
    icon_code = db.Column(db.Integer)
    color_hex = db.Column(db.Integer)
    user_id = db.Column(db.String(36), db.ForeignKey('user.id'))

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "value": self.value,
            "status": self.status,
            "icon_code": self.icon_code,
            "color_hex": self.color_hex
        }