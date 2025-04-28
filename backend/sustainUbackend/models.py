from django.db import models
from django.contrib.auth.models import AbstractUser, Group, Permission
from django.utils.translation import gettext_lazy as _

class User(AbstractUser):
    email = models.EmailField(unique=True)
    role = models.CharField(
        max_length=20,
        choices=[("student", "Student"), ("admin", "Admin"), ("restaurant", "Restaurant")],
        default="student"
    )
    # ── new “current” counters ──────────────────────────
    available_swipes = models.IntegerField(
        default=0,
        help_text="How many swipes this user has available right now",
    )
    points = models.IntegerField(
        default=0,
        help_text="How many incentive points this user has right now",
    )

    # override AbstractUser.groups to avoid reverse-accessor collision
    groups = models.ManyToManyField(
        Group,
        verbose_name=_('groups'),
        blank=True,
        help_text=_('The groups this user belongs to.'),
        related_name='sustainubackend_users',
        related_query_name='sustainubackend_user',
    )
    # override AbstractUser.user_permissions likewise
    user_permissions = models.ManyToManyField(
        Permission,
        verbose_name=_('user permissions'),
        blank=True,
        help_text=_('Specific permissions for this user.'),
        related_name='sustainubackend_user_permissions',
        related_query_name='sustainubackend_user_permission',
    )


    def __str__(self):
        # AbstractUser already has `username` (and we’ve enforced unique email)
        return self.username


class MealSwipe(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    available_swipes = models.IntegerField()
    requested_by = models.ForeignKey(
        User, null=True, blank=True,
        related_name="requested_swipes",
        on_delete=models.SET_NULL
    )
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username}: {self.available_swipes} swipes"


class FoodItem(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(null=True, blank=True)
    location = models.CharField(max_length=200)
    posted_by = models.ForeignKey(
        User, on_delete=models.CASCADE,
        related_name="posted_food"
    )
    claimed_by = models.ForeignKey(
        User, null=True, blank=True,
        related_name="claimed_food",
        on_delete=models.SET_NULL
    )
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


class RestaurantDeal(models.Model):
    restaurant_name = models.CharField(max_length=150)
    deal_description = models.TextField()
    location = models.CharField(max_length=200)
    posted_by = models.ForeignKey(
        User, on_delete=models.CASCADE,
        related_name="posted_deals"
    )
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.restaurant_name


class Incentive(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    points = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.user.username}: {self.points} pts"
