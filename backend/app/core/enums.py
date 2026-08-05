from enum import Enum


class UserRole(str, Enum):
    FARMER = "farmer"
    VETERINARIAN = "veterinarian"
    ADMIN = "admin"