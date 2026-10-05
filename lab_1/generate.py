import csv
import random
from faker import Faker

fake = Faker(['ru_RU', 'en_US'])
NUM_RECORDS = 1000

print("Генерация данных началась...")

# 1. star_cluster (Скопления)
cluster_types = ['Шаровое', 'Рассеянное', 'Карликовое', 'Сверхскопление']
clusters = []
for i in range(1, NUM_RECORDS + 1):
    parent = random.randint(1, i - 1) if i > 10 and random.random() > 0.4 else None
    clusters.append({
        'name': f"Скопление {fake.city()} {fake.word().upper()}-{i}",
        'coord_x': round(random.uniform(-10000, 10000), 2),
        'coord_y': round(random.uniform(-10000, 10000), 2),
        'coord_z': round(random.uniform(-10000, 10000), 2),
        'cluster_type': random.choice(cluster_types),
        'parent_cluster_id': parent if parent else ''
    })

with open('star_cluster.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['name', 'coord_x', 'coord_y', 'coord_z', 'cluster_type', 'parent_cluster_id'])
    writer.writeheader()
    writer.writerows(clusters)

# 2. planet (Планеты)
atmospheres = ['Кислородная', 'Азотная', 'Углекислотная', 'Метановая', 'Отсутствует']
planets = []
for i in range(1, NUM_RECORDS + 1):
    planets.append({
        'name': f"Планета {fake.first_name()}-{i}",
        'radius': round(random.uniform(1000, 70000), 2),
        'coord_x': round(random.uniform(-5000, 5000), 2),
        'coord_y': round(random.uniform(-5000, 5000), 2),
        'atmosphere_type': random.choice(atmospheres),
        'cluster_id': random.randint(1, NUM_RECORDS)
    })

with open('planet.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['name', 'radius', 'coord_x', 'coord_y', 'atmosphere_type', 'cluster_id'])
    writer.writeheader()
    writer.writerows(planets)

# 3. spaceport (Космодромы)
spaceports = []
for i in range(1, NUM_RECORDS + 1):
    spaceports.append({
        'name': f"Космодром {fake.company()}",
        'coord_x': round(random.uniform(-500, 500), 2),
        'coord_y': round(random.uniform(-500, 500), 2),
        'ship_capacity': random.randint(10, 500),
        'planet_id': random.randint(1, NUM_RECORDS)
    })

with open('spaceport.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['name', 'coord_x', 'coord_y', 'ship_capacity', 'planet_id'])
    writer.writeheader()
    writer.writerows(spaceports)

# 4. spaceship (Корабли)
models = ['Галактический Крейсер', 'Грузовой Транспорт', 'Разведчик', 'Пассажирский Лайнер', 'Истребитель']
spaceships = []
for i in range(1, NUM_RECORDS + 1):
    spaceships.append({
        'name': f"Корабль '{fake.color_name().capitalize()} {fake.word().capitalize()}'",
        'registration_number': f"REG-{i:05d}-{random.randint(100, 999)}",
        'capacity': random.randint(2, 2000),
        'model': random.choice(models),
        'max_speed': round(random.uniform(1000, 99999), 2)
    })

with open('spaceship.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['name', 'registration_number', 'capacity', 'model', 'max_speed'])
    writer.writeheader()
    writer.writerows(spaceships)

# 5. person (Люди / Персонажи)
races = ['Человек', 'Марсианин', 'Сатир', 'Венерианец', 'Киборг', 'Эльф']
persons = []
for i in range(1, NUM_RECORDS + 1):
    persons.append({
        'full_name': fake.name(),
        'birth_date': fake.date_of_birth(minimum_age=18, maximum_age=150).strftime('%Y-%m-%d'),
        'race': random.choice(races),
        'passport_code': f"PASS-{i:05d}-{random.randint(1000, 9999)}",
        'home_planet': f"Планета {fake.city()}"
    })

with open('person.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['full_name', 'birth_date', 'race', 'passport_code', 'home_planet'])
    writer.writeheader()
    writer.writerows(persons)

# 6. flight_arrival (Прилёты)
purposes = ['Туризм', 'Рабочая командировка', 'Дипломатия', 'Переезд', 'Торговля', 'Исследования']
arrivals = []
for i in range(1, 3 * NUM_RECORDS + 1):
    arrivals.append({
        'person_id': random.randint(1, NUM_RECORDS),
        'spaceship_id': random.randint(1, NUM_RECORDS),
        'spaceport_id': random.randint(1, NUM_RECORDS),
        'flight_number': f"FL-{random.randint(100, 999)}-{i}",
        'arrival_datetime': fake.date_time_between(start_date='-2y', end_date='now').strftime('%Y-%m-%d %H:%M:%S'),
        'seat_number': f"{random.randint(1, 60)}{random.choice(['A', 'B', 'C', 'D'])}",
        'purpose_of_visit': random.choice(purposes)
    })

with open('flight_arrival.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['person_id', 'spaceship_id', 'spaceport_id', 'flight_number', 'arrival_datetime', 'seat_number', 'purpose_of_visit'])
    writer.writeheader()
    writer.writerows(arrivals)

print("Все 6 CSV-файлов успешно сгенерированы по 1000 записей!")