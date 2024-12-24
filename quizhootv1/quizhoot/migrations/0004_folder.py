# Generated by Django 5.1.3 on 2024-12-23 14:46

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('quizhoot', '0003_rename_corect_ans_quiz_correct_answer_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='Folder',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('folder_name', models.CharField(db_column='folder_name', max_length=255)),
                ('sets', models.ManyToManyField(blank=True, related_name='folders', to='quizhoot.set')),
                ('user_id', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='folders', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'db_table': 'Folder',
            },
        ),
    ]
