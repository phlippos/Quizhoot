# Generated by Django 5.1.3 on 2024-12-09 21:08

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('quizhoot', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Quiz',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('result', models.FloatField(db_column='result')),
                ('corect_ans', models.IntegerField(db_column='correct_answer')),
                ('incorrect_ans', models.IntegerField(db_column='incorrect_answer')),
                ('quiz_type', models.BooleanField(db_column='quiz_type')),
            ],
        ),
        migrations.AlterField(
            model_name='set_flashcard',
            name='user_id',
            field=models.ForeignKey(db_column='user_id', on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL),
        ),
        migrations.CreateModel(
            name='Quiz_User_Set',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('quiz_id', models.ForeignKey(db_column='quiz_id', on_delete=django.db.models.deletion.CASCADE, to='quizhoot.quiz')),
                ('set_id', models.ForeignKey(db_column='set_id', on_delete=django.db.models.deletion.CASCADE, to='quizhoot.set')),
                ('user_id', models.ForeignKey(db_column='user_id', on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
