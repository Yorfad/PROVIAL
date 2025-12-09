
import pandas as pd
import datetime
import os

def generate_sql():
    try:
        excel_file = 'Libro1.xlsx'
        if not os.path.exists(excel_file):
            print(f"Error: {excel_file} not found.")
            return

        df = pd.read_excel(excel_file, header=None)
        
        with open('import_brigadas.sql', 'w', encoding='utf-8') as f:
            f.write("-- Importacion de brigadas desde Excel\n")
            f.write("-- Generated automatically\n\n")
            
            for index, row in df.iterrows():
                # Skip header or empty rows
                if index == 0 or pd.isna(row[1]):
                    continue

                # Mapping based on inspection:
                # Col 1: Chapa
                # Col 2: Nombre
                # Col 3: Licencia Num
                # Col 4: Licencia Tipo
                # Col 7: Vigencia (Status)

                chapa = str(row[1]).strip()
                if chapa.endswith('.0'): chapa = chapa[:-2] # Remove .0 from floats
                
                nombre = str(row[2]).strip()
                licencia_num = str(row[3]).strip()
                licencia_tipo = str(row[4]).strip()
                vigencia_status = str(row[7]).strip().upper()
                
                # Logic for date based on status
                if 'VIGENTE' in vigencia_status:
                    vigencia_str = '2026-12-31'
                elif 'VENCIDA' in vigencia_status:
                    vigencia_str = '2024-01-01'
                else:
                    vigencia_str = '2025-01-01' # Default
                    
                username = f"brigada_{chapa.lower().replace(' ', '')}"
                
                sql = f"""
INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, activo)
VALUES (
    '{username}',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    '{nombre}',
    '{chapa}',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    TRUE
) ON CONFLICT (username) DO NOTHING;
"""
                f.write(sql)
                
        print("import_brigadas.sql generated successfully.")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    generate_sql()
