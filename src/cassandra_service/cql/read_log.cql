SELECT userId, timestamp, action, parameters, tags
FROM logs
WHERE userId = %s 
LIMIT %s