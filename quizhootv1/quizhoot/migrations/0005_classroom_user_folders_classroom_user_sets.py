# Generated by Django 5.1.3 on 2024-12-24 19:35

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('quizhoot', '0004_folder'),
    ]

    operations = [
        migrations.AddField(
            model_name='classroom_user',
            name='folders',
            field=models.ManyToManyField(blank=True, related_name='classrooms', to='quizhoot.folder'),
        ),
        migrations.AddField(
            model_name='classroom_user',
            name='sets',
            field=models.ManyToManyField(blank=True, related_name='classrooms', to='quizhoot.set'),
        ),
    ]
