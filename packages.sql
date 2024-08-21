CREATE OR REPLACE PACKAGE OrderProcessing AS
    PROCEDURE ProcessOrder(p_order_xml IN CLOB);
    FUNCTION GetOrderItems(p_order_id IN NUMBER) RETURN SYS_REFCURSOR;
END OrderProcessing;
/
