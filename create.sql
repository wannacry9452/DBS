-- 1. ӨРТӨӨ хүснэгт
CREATE TABLE Station (
    station_code VARCHAR(10) PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- 2. МАРШРУТ хүснэгт
CREATE TABLE Route (
    route_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- 3. МАРШРУТ_ДАЙРНА (Өртөө ба Маршрутын M:N холбоо)
CREATE TABLE Route_Station (
    route_id VARCHAR(10) REFERENCES Route(route_id) ON DELETE CASCADE,
    station_code VARCHAR(10) REFERENCES Station(station_code) ON DELETE CASCADE,
    stop_order INT NOT NULL CHECK (stop_order > 0),
    distance_km INT NOT NULL CHECK (distance_km >= 0),
    PRIMARY KEY (route_id, station_code)
);

-- 4. ЗЭРГЭЛДЭЭ_ӨРТӨӨ (Өртөөний рекурсив M:N холбоо)
CREATE TABLE Adjacent_Station (
    station_code1 VARCHAR(10) REFERENCES Station(station_code) ON DELETE CASCADE,
    station_code2 VARCHAR(10) REFERENCES Station(station_code) ON DELETE CASCADE,
    PRIMARY KEY (station_code1, station_code2),
    CHECK (station_code1 <> station_code2)
);

-- 5. АЯЛАЛ хүснэгт
CREATE TABLE Journey (
    journey_no VARCHAR(20) PRIMARY KEY,
    journey_date DATE NOT NULL,
    route_id VARCHAR(10) REFERENCES Route(route_id) ON DELETE RESTRICT
);

-- 6. ВАГОН хүснэгт (Эцэг)
CREATE TABLE Wagon (
    wagon_no VARCHAR(20) PRIMARY KEY,
    journey_no VARCHAR(20) REFERENCES Journey(journey_no) ON DELETE CASCADE,
    category VARCHAR(20) NOT NULL CHECK (category IN ('Купе', 'Плацкарт', 'Нийтийн'))
);

-- 7. КУПЕ хүснэгт (ISA хүүхэд)
CREATE TABLE Coupe (
    wagon_no VARCHAR(20) PRIMARY KEY REFERENCES Wagon(wagon_no) ON DELETE CASCADE,
    room_count INT NOT NULL CHECK (room_count > 0)
);

-- 8. ПЛАЦКАРТ хүснэгт (ISA хүүхэд)
CREATE TABLE Platzkart (
    wagon_no VARCHAR(20) PRIMARY KEY REFERENCES Wagon(wagon_no) ON DELETE CASCADE,
    compartment_count INT NOT NULL CHECK (compartment_count > 0)
);

-- 9. СУУДАЛ хүснэгт (Сул entity)
CREATE TABLE Seat (
    wagon_no VARCHAR(20) REFERENCES Wagon(wagon_no) ON DELETE CASCADE,
    seat_no INT NOT NULL CHECK (seat_no > 0),
    PRIMARY KEY (wagon_no, seat_no)
);

-- 10. ЗОРЧИГЧ хүснэгт
CREATE TABLE Passenger (
    register_no VARCHAR(10) PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL
);

-- 11. АЖИЛТАН хүснэгт
CREATE TABLE Employee (
    emp_code VARCHAR(10) PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- 12. АЖИЛТАН_УТАС (Олон утгат атрибут)
CREATE TABLE Employee_Phone (
    emp_code VARCHAR(10) REFERENCES Employee(emp_code) ON DELETE CASCADE,
    phone VARCHAR(15) NOT NULL,
    PRIMARY KEY (emp_code, phone)
);

-- 13. ТАСАЛБАР хүснэгт
-- Онцгой дүрэм 1 хэрэгжүүлэхийн тулд start_station болон end_station нэмсэн
CREATE TABLE Ticket (
    ticket_id SERIAL PRIMARY KEY,
    price NUMERIC(12,2) NOT NULL CHECK (price >= 0),
    emp_code VARCHAR(10) REFERENCES Employee(emp_code) ON DELETE SET NULL,
    register_no VARCHAR(10) REFERENCES Passenger(register_no) ON DELETE RESTRICT,
    wagon_no VARCHAR(20) NOT NULL,
    seat_no INT NOT NULL,
    start_station VARCHAR(10) NOT NULL REFERENCES Station(station_code),
    end_station VARCHAR(10) NOT NULL REFERENCES Station(station_code),
    status VARCHAR(20) DEFAULT 'Баталгаажсан' CHECK (status IN ('Хүлээгдэж буй', 'Төлбөр хийгдсэн', 'Баталгаажсан', 'Цуцлагдсан', 'Буцаалт хийгдсэн')),
    FOREIGN KEY (wagon_no, seat_no) REFERENCES Seat(wagon_no, seat_no) ON DELETE RESTRICT,
    CHECK (start_station <> end_station)
);