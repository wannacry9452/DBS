-- 1. Өртөө
INSERT INTO Station (station_code, name) VALUES 
('UB', 'Улаанбаатар'), ('DZ', 'Дархан'), ('ER', 'Эрдэнэт'), ('SU', 'Сүхбаатар'), ('ZO', 'Зүүнхараа');

-- 2. Маршрут
INSERT INTO Route (route_id, name) VALUES 
('R1', 'Улаанбаатар - Эрдэнэт'), ('R2', 'Улаанбаатар - Сүхбаатар');

-- 3. Маршрутын дараалал ба зай
INSERT INTO Route_Station (route_id, station_code, stop_order, distance_km) VALUES
('R1', 'UB', 1, 0), ('R1', 'DZ', 2, 230), ('R1', 'ER', 3, 390),
('R2', 'UB', 1, 0), ('R2', 'ZO', 2, 180), ('R2', 'DZ', 3, 230), ('R2', 'SU', 4, 380);

-- 4. Зэргэлдээ өртөө
INSERT INTO Adjacent_Station (station_code1, station_code2) VALUES
('UB', 'ZO'), ('ZO', 'DZ'), ('DZ', 'ER'), ('DZ', 'SU');

-- 5. Аялал
INSERT INTO Journey (journey_no, journey_date, route_id)
SELECT 'J' || generate_series(1, 5), CURRENT_DATE - (random() * 30)::int, 'R1';
INSERT INTO Journey (journey_no, journey_date, route_id)
SELECT 'J' || generate_series(6, 10), CURRENT_DATE - (random() * 30)::int, 'R2';

-- 6. Вагон (Аялал бүрд 3 вагон)
INSERT INTO Wagon (wagon_no, journey_no, category)
SELECT 'W' || j || '_' || v, 'J' || j, 
       CASE WHEN v=1 THEN 'Купе' WHEN v=2 THEN 'Плацкарт' ELSE 'Нийтийн' END
FROM generate_series(1, 10) j, generate_series(1, 3) v;

-- 7. Купе, Плацкарт
INSERT INTO Coupe (wagon_no, room_count)
SELECT wagon_no, 9 FROM Wagon WHERE category = 'Купе';

INSERT INTO Platzkart (wagon_no, compartment_count)
SELECT wagon_no, 9 FROM Wagon WHERE category = 'Плацкарт';

-- 8. Суудал (Вагон бүрд 30 суудал)
INSERT INTO Seat (wagon_no, seat_no)
SELECT w.wagon_no, s
FROM Wagon w, generate_series(1, 30) s;

-- 9. Зорчигч (50 зорчигч)
INSERT INTO Passenger (register_no, last_name, first_name)
SELECT 'RD' || lpad(i::text, 4, '0'), 'Овог' || i, 'Нэр' || i
FROM generate_series(1, 50) i;

-- 10. Ажилтан (5 ажилтан)
INSERT INTO Employee (emp_code, name)
SELECT 'E0' || i, 'Кассчин' || i FROM generate_series(1, 5);

INSERT INTO Employee_Phone (emp_code, phone)
SELECT 'E0' || i, '991100' || lpad(i::text, 2, '0') FROM generate_series(1, 5);

-- 11. Тасалбар (Гүйлгээний хүснэгтэд 250 мөр)
INSERT INTO Ticket (price, emp_code, register_no, wagon_no, seat_no, start_station, end_station, status)
SELECT 
    (random() * 40000 + 10000)::numeric(12,2),
    'E0' || (floor(random() * 5 + 1)::int),
    'RD' || lpad((floor(random() * 50 + 1)::int)::text, 4, '0'),
    'W' || (floor(random() * 10 + 1)::int) || '_' || (floor(random() * 3 + 1)::int),
    floor(random() * 30 + 1)::int,
    'UB',
    CASE WHEN random() > 0.5 THEN 'DZ' ELSE 'ER' END,
    'Баталгаажсан'
FROM generate_series(1, 250);