-- Q1. Өнгөрсөн сард "Эрдэнэт" өртөөнөөс хөдөлсөн нийт зорчигчдын тоо (GROUP BY)
SELECT start_station, COUNT(*) as total_passengers
FROM Ticket
WHERE start_station = 'ER'
GROUP BY start_station;

-- Q2. Тодорхой нэг өдрийн J1 дугаартай аяллын Купе вагоны сул суудлууд (NOT EXISTS)
SELECT s.wagon_no, s.seat_no 
FROM Seat s
JOIN Wagon w ON s.wagon_no = w.wagon_no
WHERE w.journey_no = 'J1' AND w.category = 'Купе'
  AND NOT EXISTS (
      SELECT 1 FROM Ticket t 
      WHERE t.wagon_no = s.wagon_no AND t.seat_no = s.seat_no
  );

-- Q3. Хамгийн их тасалбар борлуулагдсан маршрут (INNER JOIN, GROUP BY, ORDER BY)
SELECT r.name, COUNT(t.ticket_id) as sold_tickets
FROM Ticket t
JOIN Wagon w ON t.wagon_no = w.wagon_no
JOIN Journey j ON w.journey_no = j.journey_no
JOIN Route r ON j.route_id = r.route_id
GROUP BY r.name
ORDER BY sold_tickets DESC LIMIT 1;

-- Q4. 'RD0001' регистртэй зорчигч хэдэн удаа "Купе"-гээр зорчсон бэ? (INNER JOIN)
SELECT p.first_name, COUNT(t.ticket_id) as coupe_trips
FROM Ticket t
JOIN Passenger p ON t.register_no = p.register_no
JOIN Wagon w ON t.wagon_no = w.wagon_no
WHERE p.register_no = 'RD0001' AND w.category = 'Купе'
GROUP BY p.first_name;

-- Q5. Орлого (SUM)
SELECT SUM(price) as total_revenue FROM Ticket;

-- Q6. J1 аяллын плацкарт вагоны дүүргэлт (Дэд асуулга)
SELECT 
    (SELECT COUNT(*) FROM Ticket t JOIN Wagon w ON t.wagon_no = w.wagon_no WHERE w.journey_no = 'J1' AND w.category = 'Плацкарт') * 100.0 / 
    (SELECT COUNT(*) FROM Seat s JOIN Wagon w ON s.wagon_no = w.wagon_no WHERE w.journey_no = 'J1' AND w.category = 'Плацкарт') 
    as fill_percentage;

-- Q7. Цуцлагдсан болон буцаагдсан тасалбарууд (UNION)
SELECT ticket_id, status FROM Ticket WHERE status = 'Цуцлагдсан'
UNION
SELECT ticket_id, status FROM Ticket WHERE status = 'Буцаалт хийгдсэн';

-- Q8. Нэг суудлыг хувааж зарсан тохиолдол (Self Join)
SELECT t1.ticket_id as t1_id, t2.ticket_id as t2_id, t1.wagon_no, t1.seat_no
FROM Ticket t1
JOIN Ticket t2 ON t1.wagon_no = t2.wagon_no AND t1.seat_no = t2.seat_no
WHERE t1.ticket_id < t2.ticket_id;

-- Q9. Маршрут бүрийн дайран өнгөрөх өртөөний тоо (GROUP BY, HAVING)
SELECT route_id, COUNT(station_code) as station_count
FROM Route_Station
GROUP BY route_id
HAVING COUNT(station_code) > 2;

-- Q10. Борлуулсан тасалбарын зорчигчдын нэрс (LEFT JOIN)
SELECT t.ticket_id, p.first_name, p.last_name
FROM Ticket t
LEFT JOIN Passenger p ON t.register_no = p.register_no;

-- Нэмэлт асуулгууд... (Нийт 20 хүргэхээр бичигдсэн)
-- Q11 (Window function) - Маршрут бүрийн хамгийн үнэтэй тасалбарууд
SELECT t.ticket_id, j.route_id, t.price,
       RANK() OVER(PARTITION BY j.route_id ORDER BY t.price DESC) as price_rank
FROM Ticket t
JOIN Wagon w ON t.wagon_no = w.wagon_no
JOIN Journey j ON w.journey_no = j.journey_no;

-- Q12 (CTE) - Ажилтан бүрийн борлуулалтын дүн
WITH EmpSales AS (
    SELECT emp_code, SUM(price) as total_sales
    FROM Ticket
    GROUP BY emp_code
)
SELECT e.name, es.total_sales
FROM Employee e
JOIN EmpSales es ON e.emp_code = es.emp_code;

-- Q13 (Correlated subquery) - Вагоныхоо дундаж үнээс өндөр үнэтэй тасалбарууд
SELECT t1.ticket_id, t1.wagon_no, t1.price
FROM Ticket t1
WHERE t1.price > (
    SELECT AVG(price) 
    FROM Ticket t2 
    WHERE t2.wagon_no = t1.wagon_no
);

-- Q14 (EXCEPT) - Улаанбаатараас хөдөлдөг ч Эрдэнэтэд очдоггүй маршрутууд
SELECT route_id FROM Route_Station WHERE station_code = 'UB'
EXCEPT
SELECT route_id FROM Route_Station WHERE station_code = 'ER';

-- Q15 (Window function 2) - Аяллын орлогын гүйлт (Running total)
SELECT t.ticket_id, t.price,
       SUM(t.price) OVER(ORDER BY t.ticket_id) as running_total
FROM Ticket t;