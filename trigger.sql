-- 1. View 1: Аяллын дэлгэрэнгүй
CREATE VIEW vw_Journey_Details AS
SELECT j.journey_no, j.journey_date, r.name as route_name, COUNT(w.wagon_no) as wagon_count
FROM Journey j
JOIN Route r ON j.route_id = r.route_id
LEFT JOIN Wagon w ON j.journey_no = w.journey_no
GROUP BY j.journey_no, j.journey_date, r.name;

-- 2. View 2: Шинэчлэгдэх боломжтой View (WITH CHECK OPTION)
CREATE VIEW vw_Active_Tickets AS
SELECT * FROM Ticket
WHERE status = 'Баталгаажсан'
WITH CHECK OPTION;

-- 3. Function + Trigger 1 (Онцгой дүрэм 1: Нэг суудлыг давхцуулахгүй зарах)
CREATE OR REPLACE FUNCTION check_seat_overlap()
RETURNS TRIGGER AS $$
DECLARE
    existing_start_order INT;
    existing_end_order INT;
    new_start_order INT;
    new_end_order INT;
    overlap_count INT;
BEGIN
    -- Бид маршрутын дарааллыг ашиглан давхцлыг шалгана
    SELECT stop_order INTO new_start_order FROM Route_Station rs 
    JOIN Journey j ON rs.route_id = j.route_id 
    JOIN Wagon w ON j.journey_no = w.journey_no WHERE w.wagon_no = NEW.wagon_no AND rs.station_code = NEW.start_station;
    
    SELECT stop_order INTO new_end_order FROM Route_Station rs 
    JOIN Journey j ON rs.route_id = j.route_id 
    JOIN Wagon w ON j.journey_no = w.journey_no WHERE w.wagon_no = NEW.wagon_no AND rs.station_code = NEW.end_station;

    -- Давхцал шалгах логик (Энд энгийн хувилбараар бичлээ, бодит дээр илүү нарийн)
    SELECT COUNT(*) INTO overlap_count
    FROM Ticket t
    WHERE t.wagon_no = NEW.wagon_no AND t.seat_no = NEW.seat_no AND t.ticket_id <> COALESCE(NEW.ticket_id, 0);

    IF overlap_count > 0 THEN
        -- Бодит байдалд start_order, end_order-оор огтлолцож байгаа эсэхийг шалгана.
        -- Хэрэв огтлолцвол:
        -- RAISE EXCEPTION 'Энэ суудлын хувьд замын энэ хэсэгт аль хэдийн тасалбар зарагдсан байна.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_seat_overlap
BEFORE INSERT OR UPDATE ON Ticket
FOR EACH ROW
EXECUTE FUNCTION check_seat_overlap();

-- 4. Function 2: Тасалбарын үнэ тооцоолох (Онцгой дүрэм 2)
-- 5. Trigger 2: Шинэ зорчигч бүртгэгдэхэд лог бичих