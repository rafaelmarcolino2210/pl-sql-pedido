CREATE OR REPLACE PACKAGE BODY OrderProcessing AS

    PROCEDURE ProcessOrder(p_order_xml IN CLOB) IS
        v_order_id Orders.OrderId%TYPE;
        v_exists NUMBER;
        CURSOR c_items IS
            SELECT
                xt.ProductName,
                xt.Quantity,
                xt.Price
            FROM XMLTABLE(
                '/Order/Items/Item'
                PASSING XMLTYPE(p_order_xml)
                COLUMNS
                    ProductName VARCHAR2(100) PATH 'ProductName',
                    Quantity NUMBER PATH 'Quantity',
                    Price NUMBER PATH 'Price'
            ) xt;
    BEGIN
        -- Verifica se o pedido já existe
        SELECT COUNT(*)
        INTO v_exists
        FROM Orders
        WHERE CustomerName = (
            SELECT xt.CustomerName
            FROM XMLTABLE(
                '/Order'
                PASSING XMLTYPE(p_order_xml)
                COLUMNS
                    CustomerName VARCHAR2(100) PATH 'CustomerName'
            ) xt
        )
        AND OrderDate = (
            SELECT xt.OrderDate
            FROM XMLTABLE(
                '/Order'
                PASSING XMLTYPE(p_order_xml)
                COLUMNS
                    OrderDate DATE PATH 'OrderDate'
            ) xt
        );

        IF v_exists > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Já existe um pedido para esse mesmo cliente na data informada.');
            RETURN;
        END IF;

        INSERT INTO Orders (CustomerName, OrderDate)
        SELECT
            xt.CustomerName,
            xt.OrderDate
        FROM XMLTABLE(
            '/Order'
            PASSING XMLTYPE(p_order_xml)
            COLUMNS
                CustomerName VARCHAR2(100) PATH 'CustomerName',
                OrderDate DATE PATH 'OrderDate'
        ) xt;
     
        SELECT OrderId
        INTO v_order_id
        FROM Orders
        WHERE CustomerName = (
            SELECT xt.CustomerName
            FROM XMLTABLE(
                '/Order'
                PASSING XMLTYPE(p_order_xml)
                COLUMNS
                    CustomerName VARCHAR2(100) PATH 'CustomerName'
            ) xt
        )
        AND OrderDate = (
            SELECT xt.OrderDate
            FROM XMLTABLE(
                '/Order'
                PASSING XMLTYPE(p_order_xml)
                COLUMNS
                    OrderDate DATE PATH 'OrderDate'
            ) xt
        )
        ORDER BY OrderId DESC
        FETCH FIRST ROW ONLY;

        DBMS_OUTPUT.PUT_LINE('Pedido Inserido com ID: ' || v_order_id);

        FOR item IN c_items LOOP
            DECLARE
                v_item_exists NUMBER;
            BEGIN
                SELECT COUNT(*)
                INTO v_item_exists
                FROM OrderItems
                WHERE OrderId = v_order_id
                AND ProductName = item.ProductName;

                IF v_item_exists = 0 THEN
                    INSERT INTO OrderItems (OrderId, ProductName, Quantity, Price)
                    VALUES (v_order_id, item.ProductName, item.Quantity, item.Price);

                    DBMS_OUTPUT.PUT_LINE('Item inserido: ' || item.ProductName || ', Quantidade: ' || item.Quantity || ', Valor: ' || item.Price);
                ELSE
                    -- Log message if item already exists
                    DBMS_OUTPUT.PUT_LINE('O item já existe: ' || item.ProductName);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Erro ao inserir: ' || SQLERRM);
            END;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao processar: ' || SQLERRM);
            RAISE;
    END ProcessOrder;

    FUNCTION GetOrderItems(p_order_id IN NUMBER) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
        SELECT ProductName, Quantity, Price
        FROM OrderItems
        WHERE OrderId = p_order_id;
        RETURN v_cursor;
    END GetOrderItems;

END OrderProcessing;
/

