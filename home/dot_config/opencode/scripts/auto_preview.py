# Si el agente sabe en qué puerto arrancó
python auto_preview.py register 3000

# Si no hay nada registrado, escanea solo
python auto_preview.py status  # detecta automáticamente puertos abiertos

# Escaneo manual
python auto_preview.py scan