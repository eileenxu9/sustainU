from rest_framework import serializers
from .models import User, MealSwipe, FoodItem, RestaurantDeal, Incentive

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model  = User
        fields = [
            'id',
            'username',
            'email',
            'role',
            'available_swipes',
            'points',
        ]
    
class MealSwipeSerializer(serializers.ModelSerializer):
    class Meta:
        model = MealSwipe
        fields = '__all__'

class FoodItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = FoodItem
        fields = '__all__'
        read_only_fields = ['posted_by']

class RestaurantDealSerializer(serializers.ModelSerializer):
    class Meta:
        model = RestaurantDeal
        fields = '__all__'

class IncentiveSerializer(serializers.ModelSerializer):
    class Meta:
        model = Incentive
        fields = '__all__'
