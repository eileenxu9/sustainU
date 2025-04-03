from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    email = models.EmailField(unique=True)
    role = models.CharField(max_length=20, choices=[("student", "Student"), ("admin", "Admin"), ("restaurant", "Restaurant")], default="student")

    def __str__(self):
        return self.name

class MealSwipe(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    available_swipes = models.IntegerField()
    requested_by = models.ForeignKey(User, null=True, blank=True, related_name="requested_swipes", on_delete=models.SET_NULL)
    timestamp = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return self.name

class FoodItem(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(null=True, blank=True)
    location = models.CharField(max_length=200)
    posted_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name="posted_food")
    claimed_by = models.ForeignKey(User, null=True, blank=True, related_name="claimed_food", on_delete=models.SET_NULL)
    timestamp = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return self.name

class RestaurantDeal(models.Model):
    restaurant_name = models.CharField(max_length=150)
    deal_description = models.TextField()
    location = models.CharField(max_length=200)
    posted_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name="posted_deals")
    timestamp = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return self.name

class Incentive(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    points = models.IntegerField(default=0)
    def __str__(self):
        return self.namev