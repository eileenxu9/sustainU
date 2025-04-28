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
    # expose the poster’s username, but don’t expect it in the input JSON
    posted_by = serializers.ReadOnlyField(source='posted_by.username')

    class Meta:
        model = RestaurantDeal
        # explicitly list the fields so we can mark read_only_fields
        fields = [
            'id',
            'restaurant_name',
            'deal_description',
            'location',
            'timestamp',
            'posted_by',
        ]
        read_only_fields = ['id', 'timestamp', 'posted_by']

class IncentiveSerializer(serializers.ModelSerializer):
    class Meta:
        model = Incentive
        fields = '__all__'
