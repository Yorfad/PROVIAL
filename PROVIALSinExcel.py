import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
from tkcalendar import DateEntry
from datetime import datetime

# --- INICIO CAMBIO: Versión mejorada de SearchableEntry ---
VEHICULO_MARCAS = sorted(["Toyota", "Honda", "Nissan", "Jeep", "BMW", "Mitsubishi", "Suzuki", "Hyundai", "Mazda", "Chevrolet", "Freightliner", "International", "Volvo", "Italika", "Kia", "Volkswagen", "Ford", "Audi", "JAC", "Hino", "Otro"])
VEHICULO_TIPOS = sorted(["Motocicleta", "Jaula Cañera", "Rastra", "Bicicleta", "Jeep", "Bus escolar", "Maquinaria", "Bus turismo", "Tractor", "Ambulancia", "Camionetilla", "Pulman", "Autopatrulla PNC", "Bus extraurbano", "Bus urbano", "Camioneta agricola", "Cisterna", "Furgon", "Mototaxi", "Microbus", "Motobicicleta", "Plataforma", "Panel", "Unidad de PROVIAL", "Grúa", "Bus institucional", "Cuatrimoto", "Doble remolque", "Tesla", "Peaton", "Fugado", "Sedan", "Pick-up", "Camión", "Bus", "Cabezal", "Otro"])

def cap_first(s):
    if not s:
        return ""
    return s[0].upper() + s[1:]


class SearchableEntry(ttk.Frame):
    """
    Widget con altura dinámica, selección corregida y un callback opcional
    para ejecutar en cada pulsación de tecla.
    """
    def __init__(self, master, values, keyrelease_callback=None, **kwargs):
        super().__init__(master, **kwargs)
        self._values = values
        self._original_values = values[:]
        self._keyrelease_callback = keyrelease_callback
        
        self.entry = ttk.Entry(self)
        self.entry.pack(fill="x", expand=True)
        
        self.entry.bind("<KeyRelease>", self._on_keyrelease)
        self.entry.bind("<FocusOut>", self._on_focusout)
        self.entry.bind("<FocusIn>", self._on_keyrelease)

        self._popup = tk.Toplevel(self)
        self._popup.wm_overrideredirect(True)
        self._popup.withdraw()

        self._listbox = tk.Listbox(self._popup, exportselection=False)
        self._listbox.pack(fill="both", expand=True)
        self._listbox.bind("<<ListboxSelect>>", self._on_listbox_select)

    def get(self):
        return self.entry.get()

    def set(self, text):
        self.entry.delete(0, tk.END)
        if text:
            self.entry.insert(0, text)

    def _update_listbox(self, values):
        self._listbox.delete(0, tk.END)
        for value in values:
            self._listbox.insert(tk.END, value)
        
        list_height = min(len(values), 7) if values else 0
        self._listbox.config(height=list_height)

    def _position_popup(self):
        x = self.entry.winfo_rootx()
        y = self.entry.winfo_rooty() + self.entry.winfo_height()
        width = self.entry.winfo_width()
        
        self._popup.geometry(f"{width}x{self._popup.winfo_reqheight()}+{x}+{y}")
        self._popup.deiconify()

    def _on_keyrelease(self, event):
        # Ejecutar el callback si existe
        if self._keyrelease_callback:
            self._keyrelease_callback(event)
            
        if event.keysym in ("Up", "Down", "Return", "Enter"):
            return 
            
        current_text = self.entry.get().lower()

        if not current_text:
            filtered = self._original_values
        else:
            filtered = [v for v in self._original_values if current_text in v.lower()]

        if filtered:
            self._update_listbox(filtered)
            self._position_popup()
        else:
            self._popup.withdraw()

    def _on_listbox_select(self, event):
        selection_indices = self._listbox.curselection()
        if selection_indices:
            selection = self._listbox.get(selection_indices[0])
            self.set(selection)
            self._popup.withdraw()
            self.entry.focus()

    def _on_focusout(self, event):
        self.after(200, self._popup.withdraw)
# --- FIN CAMBIO ---

# ==== Ventana principal ====
class ProvialApp(tk.Tk):
    def _toggle_km_rango(self):

        if self.km_rango_var.get():
            self.km_separator_label.pack(side="left")
            self.km_entry2.pack(side="left", padx=5)
        else:
            self.km_entry2.delete(0, tk.END)
            self.km_separator_label.pack_forget()
            self.km_entry2.pack_forget()
    def __init__(self):
        super().__init__()
        self.title("Registro PROVIAL")
        self.geometry("850x850") # Ajuste de tamaño para nuevos elementos

        self.vehiculos_registrados = []
        # --- INICIO CAMBIO: Listas para grúas y ajustadores ---
        self.gruas_registradas = []
        self.ajustadores_registrados = []
        # --- FIN CAMBIO ---
        
        self.authority_detail_widgets = {}
        self.socorro_detail_widgets = {}

        main_container = ttk.Frame(self)
        main_container.pack(fill="both", expand=True)

        self.canvas = tk.Canvas(main_container, borderwidth=0)
        scrollbar = ttk.Scrollbar(main_container, orient="vertical", command=self.canvas.yview)
        self.canvas.configure(yscrollcommand=scrollbar.set)

        scrollbar.pack(side="right", fill="y")
        self.canvas.pack(side="left", fill="both", expand=True)

        outer_frame = ttk.Frame(self.canvas)
        outer_frame.grid_columnconfigure(0, weight=1)
        self.canvas.create_window((0, 0), window=outer_frame, anchor="nw")

        self.scroll_frame = ttk.Frame(outer_frame)
        self.scroll_frame.grid(row=0, column=0, sticky="n")

        def actualizar_scroll(event):
            self.canvas.configure(scrollregion=self.canvas.bbox("all"))
            self.canvas.itemconfigure(self.canvas.find_all()[0], width=self.canvas.winfo_width())

        self.scroll_frame.bind("<Configure>", actualizar_scroll)

        def on_mousewheel(event):
            self.canvas.yview_scroll(int(-1*(event.delta/120)), "units")

        self.canvas.bind("<Enter>", lambda e: self.canvas.bind_all("<MouseWheel>", on_mousewheel))
        self.canvas.bind("<Leave>", lambda e: self.canvas.unbind_all("<MouseWheel>"))

        self.crear_widgets()
        

    def crear_widgets(self):
        scroll_frame = self.scroll_frame

        # ... (código de fecha, hora, sede, etc. sin cambios) ...
        # Fecha
        ttk.Label(scroll_frame, text="Fecha del hecho").pack(anchor="center")
        self.fecha = DateEntry(scroll_frame, date_pattern="dd/mm/yyyy", width=12)
        self.fecha.pack(pady=5)

        # Hora
        hora_frame = ttk.Frame(scroll_frame)
        hora_frame.pack(anchor="center")
        ttk.Label(hora_frame, text="Hora").grid(row=0, column=0)
        self.hora_var = tk.StringVar(value="06")
        self.minuto_var = tk.StringVar(value="00")
        hora_cb = ttk.Combobox(hora_frame, textvariable=self.hora_var, values=[f"{h:02}" for h in range(24)], width=5)
        minuto_cb = ttk.Combobox(hora_frame, textvariable=self.minuto_var, values=[f"{m:02}" for m in range(60)], width=5)
        hora_cb.grid(row=0, column=1, padx=5)
        minuto_cb.grid(row=0, column=2)

        # Sede
        ttk.Label(scroll_frame, text="Sede").pack()
        self.sede_entry = SearchableEntry(scroll_frame, values=sorted(["Central", "Mazatenango", "Poptún", "San Cristóbal", "Quetzaltenango", "Coatepeque", "Palin Escuintla", "Morales", "Rio Dulce"]))
        self.sede_entry.pack(pady=3, fill='x', padx=150)

        ttk.Label(scroll_frame, text="Jurisdicción").pack()
        self.jurisdiccion_entry = ttk.Entry(scroll_frame, width=30)
        self.jurisdiccion_entry.pack(pady=3)
        
        ttk.Label(scroll_frame, text="Brigada que reporta").pack()
        self.brigada_entry = ttk.Entry(scroll_frame)
        self.brigada_entry.pack(pady=3)
        # Kilómetro
        # --- NUEVO BLOQUE DE KILÓMETRO CON RANGO ---
        ttk.Label(scroll_frame, text="Kilómetro").pack()
        km_frame = ttk.Frame(scroll_frame)
        km_frame.pack(pady=3)

        # Primer campo de Kilómetro (siempre visible)
        self.km_entry1 = ttk.Entry(km_frame, width=10)
        self.km_entry1.pack(side="left", padx=5)

        # Checkbox para activar el rango
        self.km_rango_var = tk.BooleanVar()
        km_rango_chk = ttk.Checkbutton(km_frame, text="¿Rango?", 
        variable=self.km_rango_var, command=self._toggle_km_rango)
        km_rango_chk.pack(side="left", padx=5)

        # Widgets para el rango (inicialmente ocultos)
        self.km_separator_label = ttk.Label(km_frame, text="-")
        self.km_entry2 = ttk.Entry(km_frame, width=10)
        # --- FIN DEL NUEVO BLOQUE ---

        # Unidad
        ttk.Label(scroll_frame, text="Unidad").pack()
        self.unidad_entry = SearchableEntry(scroll_frame, values=sorted(["M001", "M002", "M003", "M004", "M005", "M006", "1104", "1105", "1106", "1107", "1108", "1109", "1110", "1111", "1112", "1113", "1114", "1115", "1116", "1117", "1118", "1119", "1120", "1121", "1122", "1123", "1124", "1125", "1126", "1127", "1128", "1129", "1130", "1131", "1132", "1133", "1134", "1135", "1137", "1170", "1171", "1172", "1173", "1174", "1175", "1176", "Peatonal", "002", "003", "004", "005", "006", "007", "008", "009", "010", "011", "012", "013", "014", "015", "016", "017", "018", "019", "020", "021", "022", "023", "024", "025", "026", "027", "028", "029", "030", "1139", "1138", "1137", "M007", "Otro"])) # Tu lista completa de unidades
        self.unidad_entry.pack(pady=3, fill='x', padx=150)

        # Ruta
        ttk.Label(scroll_frame, text="Ruta").pack()
        self.ruta_entry = SearchableEntry(scroll_frame, values=sorted(["CA-1 Occidente", "CA-1 Oriente", "CA-10", "CA-13", "RD-PET-03", "CA-14", "CA-2 Occidente", "CA-2 Oriente", "CA-8 Oriente", "CA-9 Norte", "CA-9 Sur", "CA-9 Sur A", "CHM-11", "CITO-180", "CIUDAD", "FTN", "PRO-1", "RD-1", "RD-10", "RD-16", "RD-3", "RD-9 Norte", "RD-AV-09", "RD-CHI-01", "RD-GUA-04-06", "RD-PET-01", "RD-PET-11", "RD-PET-13", "RD-SCH-14", "RD-SRO-03", "RD-ZA-05", "RN-01", "RN-07 E", "RN-10", "RN-11", "RN-14", "RN-15", "RN-18", "RN-19", "RUTA VAS SUR", "RUTA VAS OCC", "RUTA VAS OR", "QUE-03", "CA-11", "RD-GUA-01", "RD-GUA-16", "RD-PET-13", "RD-JUT-03", "RD-SRO-03", "RN-15-03", "RN-16", "RN-17", "RN-9S", "RD GUA-16", "RD-SM-01", "RD-SAC-11", "RD--PET-03", "RD-GUA-10", "RD-SAC-08", "RD-SOL03", "RN-05", "RD-STR-003", "RD-ESC-01", "RN-02"])) # Tu lista completa de rutas
        self.ruta_entry.pack(pady=3, fill='x', padx=150)

        self.obstruccion_frame = ObstruccionFrame(scroll_frame)
        self.obstruccion_frame.pack(fill="x", padx=10, pady=10)
        self.opciones_frame = ttk.Frame(scroll_frame)
        def actualizar_opciones(*args):
            seleccion = self.tipo_var.get()
            for frame in self.opciones_frame.winfo_children(): frame.destroy()
            opciones = {
                "Hecho de tránsito": sorted(["Persona Fallecida", "Desprendimiento De Neumatico", "Salida De Pista", "Desprendimiento De Contenedor", "Explosion De Neumatico", "Caída De Carga", "Choque", "Caída De Carga", "Colisión", "Colisión Múltiple", "Derrape", "Vehículo Incendiado", "Vuelco", "Desprendimiento", "Caída De Árbol", "Desprendimiento De Eje", "Desbalance De Carga", "Persona Atropellada", "Persona Fallecida"]),
                "Asistencia vial": sorted(["Pinchazo", "Trabajos De Carretera", "Consignación", "Ataque Armado", "Derrame", "Calentamiento", "Falta De Combustible", "Desperfectos Mecánicos", "Llamada De Atención", "Operativos", "Sanción", "Sistema Electrico", "Asistencia Al Usuario", "Doble Remolque", "Sinaprese", "Apoyo Atletismo", "Apoyo A Ciclismo", "Descarga De Batería", "Problemas De Salud", "Olvido La Llave", "Carga Sobredimensionada", "Desbalance De Carga", "Vehículo Abandonado", "Desprendimiento", "Caída De Poste", "Caída De Rama", "Operativo DGT", "Operativo PMT", "Apoyo A Digef", "Operativo Pnc Transito", "Sobrecarga", "Operativo En Conjunto", "Puesto De Atencion Al Usuario", "Incendio En Ruta"]),
                "Emergencia vial": sorted(["Acumulación De Agua", "Derrumbe", "Desbordamiento De Río", "Desprendimiento De Rocas", "Socavamiento", "Caída De Valla Publicitaría", "Hundimiento", "Caída De Puente", "Incendio Forestal", "Deslave", "Caída De Árbol", "Apoyo Antorcha"])
            }
            if seleccion in opciones:
                ttk.Label(self.opciones_frame, text="Tipo específico:").pack()
                self.tipo_especifico_entry = SearchableEntry(self.opciones_frame, values=opciones[seleccion])
                self.tipo_especifico_entry.pack(fill='x', padx=150)
        ttk.Label(scroll_frame, text="Tipo de hecho").pack()
        self.tipo_var = tk.StringVar()
        tipo_cb = ttk.Combobox(scroll_frame, textvariable=self.tipo_var, values=["Asistencia vial", "Hecho de tránsito", "Emergencia vial"])
        tipo_cb.pack(pady=5)
        tipo_cb.bind("<<ComboboxSelected>>", actualizar_opciones)
        self.opciones_frame.pack(pady=5)
        self.tipo_especifico_entry  = None
        # Daños adicionales
        ttk.Label(scroll_frame, text="Daños adicionales").pack()
        self.danios_frame = ttk.Frame(scroll_frame)
        self.danios_frame.pack(pady=3)

        self.danios_materiales_var = tk.BooleanVar()
        self.danios_infraestructura_var = tk.BooleanVar()
        
        ttk.Checkbutton(self.danios_frame, text="Daños materiales", variable=self.danios_materiales_var).grid(row=0, column=0, sticky="w", padx=5)
        ttk.Checkbutton(self.danios_frame, text="Daños a infraestructura", variable=self.danios_infraestructura_var, 
                        command=self._toggle_infra_damage_entry).grid(row=0, column=1, sticky="w", padx=5)
        
        self.infra_damage_entry = ttk.Entry(scroll_frame, width=60)

        # SECCIÓN DE VEHÍCULOS
        vehiculos_main_frame = ttk.LabelFrame(scroll_frame, text="Vehículos Involucrados")
        vehiculos_main_frame.pack(pady=(20, 5), padx=10, fill="x")
        tree_frame = ttk.Frame(vehiculos_main_frame)
        tree_frame.pack(pady=5, padx=5, fill="x")
        cols = ("#", "Tipo", "Placa", "Piloto")
        self.vehiculos_tree = ttk.Treeview(tree_frame, columns=cols, show="headings", height=5)
        for col in cols: self.vehiculos_tree.heading(col, text=col)
        self.vehiculos_tree.column("#", width=30, anchor="center")
        self.vehiculos_tree.column("Tipo", width=120)
        self.vehiculos_tree.column("Placa", width=100)
        self.vehiculos_tree.pack(side="left", fill="x", expand=True)
        tree_scrollbar = ttk.Scrollbar(tree_frame, orient="vertical", command=self.vehiculos_tree.yview)
        self.vehiculos_tree.configure(yscrollcommand=tree_scrollbar.set)
        tree_scrollbar.pack(side="right", fill="y")
        btn_frame = ttk.Frame(vehiculos_main_frame)
        btn_frame.pack(pady=5)
        ttk.Button(btn_frame, text="Agregar", command=self.agregar_vehiculo).grid(row=0, column=0, padx=5)
        ttk.Button(btn_frame, text="Editar", command=self.editar_vehiculo).grid(row=0, column=1, padx=5)
        ttk.Button(btn_frame, text="Eliminar", command=self.eliminar_vehiculo).grid(row=0, column=2, padx=5)
        ttk.Button(btn_frame, text="Subir", command=self.mover_vehiculo_arriba).grid(row=0, column=3, padx=5)
        ttk.Button(btn_frame, text="Bajar", command=self.mover_vehiculo_abajo).grid(row=0, column=4, padx=5)

        # --- INICIO CAMBIO: "MP" agregado a autoridades ---
        ttk.Label(scroll_frame, text="Autoridades presentes").pack()
        autoridades_frame = ttk.Frame(scroll_frame)
        autoridades_frame.pack(pady=3)
        self.autoridades_vars = {}
        autoridades_options = ["PMT", "PNC", "PROVIAL", "DGT", "Ejército", "MP", "COVIAL", "Caminos", "PNC DT", "PM", "Ninguna"]
        for i, auth in enumerate(autoridades_options):
            var = tk.BooleanVar()
            self.autoridades_vars[auth] = var
            chk = ttk.Checkbutton(autoridades_frame, text=auth, variable=var,
                                  command=lambda name=auth: self._toggle_details_frame(
                                      name, self.autoridades_vars, self.autoridades_details_frame, self.authority_detail_widgets))
            chk.grid(row=i//3, column=i%3, sticky="w", padx=5)
        # --- FIN CAMBIO ---
        
        self.autoridades_details_frame = ttk.Frame(scroll_frame)
        self.autoridades_details_frame.pack(fill="x", expand=True, padx=10, pady=5)
        
        ttk.Label(scroll_frame, text="Unidades de socorro").pack()
        socorro_frame = ttk.Frame(scroll_frame)
        socorro_frame.pack(pady=3)
        self.socorro_vars = {}
        socorro_options = ["Bomberos Voluntarios", "Bomberos Municipales", "CONRED", "Bomberos Departamentales", "Cruz Roja", "Ninguna"]
        for i, socorro in enumerate(socorro_options):
            var = tk.BooleanVar()
            self.socorro_vars[socorro] = var
            chk = ttk.Checkbutton(socorro_frame, text=socorro, variable=var,
                                  command=lambda name=socorro: self._toggle_details_frame(
                                      name, self.socorro_vars, self.socorro_details_frame, self.socorro_detail_widgets))
            chk.grid(row=i//3, column=i%3, sticky="w", padx=5)

        self.socorro_details_frame = ttk.Frame(scroll_frame)
        self.socorro_details_frame.pack(fill="x", expand=True, padx=10, pady=5)
        
        # --- INICIO CAMBIO: Sección de Grúas ---
        gruas_main_frame = ttk.LabelFrame(scroll_frame, text="Grúas Involucradas")
        gruas_main_frame.pack(pady=(20, 5), padx=10, fill="x")
        gruas_tree_frame = ttk.Frame(gruas_main_frame)
        gruas_tree_frame.pack(pady=5, padx=5, fill="x")
        gruas_cols = ("#", "Tipo", "Placa", "Asignado a")
        self.gruas_tree = ttk.Treeview(gruas_tree_frame, columns=gruas_cols, show="headings", height=3)
        for col in gruas_cols: self.gruas_tree.heading(col, text=col)
        self.gruas_tree.column("#", width=30, anchor="center")
        self.gruas_tree.column("Tipo", width=120)
        self.gruas_tree.column("Placa", width=100)
        self.gruas_tree.pack(side="left", fill="x", expand=True)
        gruas_scrollbar = ttk.Scrollbar(gruas_tree_frame, orient="vertical", command=self.gruas_tree.yview)
        self.gruas_tree.configure(yscrollcommand=gruas_scrollbar.set)
        gruas_scrollbar.pack(side="right", fill="y")
        gruas_btn_frame = ttk.Frame(gruas_main_frame)
        gruas_btn_frame.pack(pady=5)
        ttk.Button(gruas_btn_frame, text="Agregar Grúa", command=self.agregar_grua).grid(row=0, column=0, padx=5)
        ttk.Button(gruas_btn_frame, text="Editar Grúa", command=self.editar_grua).grid(row=0, column=1, padx=5)
        ttk.Button(gruas_btn_frame, text="Eliminar Grúa", command=self.eliminar_grua).grid(row=0, column=2, padx=5)
        # --- FIN CAMBIO ---

        # --- INICIO CAMBIO: Sección de Ajustadores ---
        ajustadores_main_frame = ttk.LabelFrame(scroll_frame, text="Ajustadores Involucrados")
        ajustadores_main_frame.pack(pady=(20, 5), padx=10, fill="x")
        ajustadores_tree_frame = ttk.Frame(ajustadores_main_frame)
        ajustadores_tree_frame.pack(pady=5, padx=5, fill="x")
        ajustadores_cols = ("#", "Nombre", "Empresa", "Asignado a")
        self.ajustadores_tree = ttk.Treeview(ajustadores_tree_frame, columns=ajustadores_cols, show="headings", height=3)
        for col in ajustadores_cols: self.ajustadores_tree.heading(col, text=col)
        self.ajustadores_tree.column("#", width=30, anchor="center")
        self.ajustadores_tree.column("Nombre", width=150)
        self.ajustadores_tree.column("Empresa", width=120)
        self.ajustadores_tree.pack(side="left", fill="x", expand=True)
        ajustadores_scrollbar = ttk.Scrollbar(ajustadores_tree_frame, orient="vertical", command=self.ajustadores_tree.yview)
        self.ajustadores_tree.configure(yscrollcommand=ajustadores_scrollbar.set)
        ajustadores_scrollbar.pack(side="right", fill="y")
        ajustadores_btn_frame = ttk.Frame(ajustadores_main_frame)
        ajustadores_btn_frame.pack(pady=5)
        ttk.Button(ajustadores_btn_frame, text="Agregar Ajustador", command=self.agregar_ajustador).grid(row=0, column=0, padx=5)
        ttk.Button(ajustadores_btn_frame, text="Editar Ajustador", command=self.editar_ajustador).grid(row=0, column=1, padx=5)
        ttk.Button(ajustadores_btn_frame, text="Eliminar Ajustador", command=self.eliminar_ajustador).grid(row=0, column=2, padx=5)
        # --- FIN CAMBIO ---

        ttk.Label(scroll_frame, text="Observaciones").pack(pady=(20, 0))
        self.observaciones_text = scrolledtext.ScrolledText(scroll_frame, height=4, width=60)
        self.observaciones_text.pack(pady=5)
        botones_frame = ttk.Frame(scroll_frame)
        botones_frame.pack(pady=20)
        ttk.Button(botones_frame, text="Generar Mensaje para Encargado", command=self.generar_mensaje_encargado_click).grid(row=0, column=0, padx=5, pady=5)
        ttk.Button(botones_frame, text="Generar Mensaje General", command=self.generar_mensaje_general_click).grid(row=0, column=1, padx=5, pady=5)
        ttk.Button(botones_frame, text="Limpiar Formulario", command=self.limpiar_formulario).grid(row=1, column=0, columnspan=2, pady=10)
            
    def _toggle_infra_damage_entry(self):
        """Muestra u oculta el campo de texto para detallar daños a infraestructura."""
        if self.danios_infraestructura_var.get():
            self.infra_damage_entry.pack(after=self.danios_frame, pady=3, padx=10)
        else:
            self.infra_damage_entry.delete(0, tk.END)
            self.infra_damage_entry.pack_forget()
            
    def _toggle_details_frame(self, name, var_dict, parent_frame, widget_dict):
        """
        Crea o destruye un frame con campos de detalle cuando se marca/desmarca un checkbox.
        """
        if "Ninguna" in name and var_dict[name].get():
            for key, var in var_dict.items():
                if key != name:
                    var.set(False)
                    if key in widget_dict:
                        widget_dict[key]['frame'].destroy()
                        del widget_dict[key]
            return

        if "Ninguna" not in name and var_dict[name].get():
            if "Ninguna" in var_dict:
                var_dict["Ninguna"].set(False)

        if var_dict[name].get():
            if name == "PROVIAL":
                return
            if name in widget_dict:
                return

            detail_frame = ttk.LabelFrame(parent_frame, text=f"Detalles de {name}")
            detail_frame.pack(fill="x", expand=True, pady=5, padx=5)

            fields = {
                "Hora de llegada": tk.StringVar(),
                "NIP/Chapa": tk.StringVar(),
                "Número de unidad": tk.StringVar(),
                "Nombre de comandante": tk.StringVar(),
                "Cantidad de elementos": tk.StringVar(),
                "Subestación": tk.StringVar(),
                "Cantidad de unidades": tk.StringVar()
            }
            
            for i, (label, var) in enumerate(fields.items()):
                ttk.Label(detail_frame, text=label).grid(row=i, column=0, sticky="w", padx=5, pady=2)
                ttk.Entry(detail_frame, textvariable=var).grid(row=i, column=1, sticky="ew", padx=5, pady=2)
            
            detail_frame.grid_columnconfigure(1, weight=1)
            
            widget_dict[name] = {'frame': detail_frame, 'vars': fields}
        else:
            if name in widget_dict:
                widget_dict[name]['frame'].destroy()
                del widget_dict[name]

    # --- MÉTODOS PARA VEHÍCULOS ---
    def agregar_vehiculo(self):
        VehiculoPopup(self, callback=self.actualizar_lista_vehiculos)

    def actualizar_lista_vehiculos(self):
        for i in self.vehiculos_tree.get_children():
            self.vehiculos_tree.delete(i)
        for i, v in enumerate(self.vehiculos_registrados, start=1):
            self.vehiculos_tree.insert("", "end", iid=i-1, values=(f"{i}", v['tipo'], v['placa'], v['estado_piloto']))
        
        # Actualizar listas de grúas y ajustadores por si cambió un vehículo asignado
        self.actualizar_lista_gruas()
        self.actualizar_lista_ajustadores()

    def editar_vehiculo(self):
        seleccion = self.vehiculos_tree.focus()
        if not seleccion:
            messagebox.showwarning("Sin selección", "Por favor, selecciona un vehículo de la lista para editar.")
            return
        index = int(seleccion)
        vehiculo_data = self.vehiculos_registrados[index]
        VehiculoPopup(self, callback=self.actualizar_lista_vehiculos, vehiculo_data=vehiculo_data, index=index)

    def eliminar_vehiculo(self):
        seleccion = self.vehiculos_tree.focus()
        if not seleccion:
            messagebox.showwarning("Sin selección", "Por favor, selecciona un vehículo de la lista para eliminar.")
            return
        if messagebox.askyesno("Confirmar", "¿Estás seguro de que deseas eliminar el vehículo seleccionado?"):
            index = int(seleccion)
            self.vehiculos_registrados.pop(index)
            # Re-asignar grúas y ajustadores que apuntaban a vehículos eliminados
            for grua in self.gruas_registradas:
                if grua.get('asignado_a_idx') == index:
                    grua['asignado_a_idx'] = -1 # Marcar como no asignado
                elif grua.get('asignado_a_idx', -1) > index:
                    grua['asignado_a_idx'] -= 1
            for ajustador in self.ajustadores_registrados:
                if ajustador.get('asignado_a_idx') == index:
                    ajustador['asignado_a_idx'] = -1
                elif ajustador.get('asignado_a_idx', -1) > index:
                    ajustador['asignado_a_idx'] -= 1

            self.actualizar_lista_vehiculos()


    def mover_vehiculo(self, direccion):
        # (código sin cambios)
        seleccion = self.vehiculos_tree.focus()
        if not seleccion:
            messagebox.showwarning("Sin selección", "Por favor, selecciona un vehículo para mover.")
            return
        index = int(seleccion)
        nuevo_foco = None
        if direccion == "arriba" and index > 0:
            self.vehiculos_registrados[index], self.vehiculos_registrados[index-1] = self.vehiculos_registrados[index-1], self.vehiculos_registrados[index]
            nuevo_foco = str(index - 1)
        elif direccion == "abajo" and index < len(self.vehiculos_registrados) - 1:
            self.vehiculos_registrados[index], self.vehiculos_registrados[index+1] = self.vehiculos_registrados[index+1], self.vehiculos_registrados[index]
            nuevo_foco = str(index + 1)
        if nuevo_foco:
            self.actualizar_lista_vehiculos()
            self.vehiculos_tree.focus(nuevo_foco)
            self.vehiculos_tree.selection_set(nuevo_foco)

    def mover_vehiculo_arriba(self): self.mover_vehiculo("arriba")
    def mover_vehiculo_abajo(self): self.mover_vehiculo("abajo")

    # --- INICIO CAMBIO: Métodos para Grúas ---
    def agregar_grua(self):
        GruaPopup(self, callback=self.actualizar_lista_gruas)

    def editar_grua(self):
        seleccion = self.gruas_tree.focus()
        if not seleccion:
            messagebox.showwarning("Sin selección", "Por favor, selecciona una grúa de la lista para editar.")
            return
        index = int(seleccion)
        grua_data = self.gruas_registradas[index]
        GruaPopup(self, callback=self.actualizar_lista_gruas, grua_data=grua_data, index=index)
    
    def eliminar_grua(self):
        seleccion = self.gruas_tree.focus()
        if not seleccion:
            messagebox.showwarning("Sin selección", "Por favor, selecciona una grúa de la lista para eliminar.")
            return
        if messagebox.askyesno("Confirmar", "¿Estás seguro de que deseas eliminar la grúa seleccionada?"):
            index = int(seleccion)
            self.gruas_registradas.pop(index)
            self.actualizar_lista_gruas()

    def actualizar_lista_gruas(self):
        for i in self.gruas_tree.get_children():
            self.gruas_tree.delete(i)
        for i, g in enumerate(self.gruas_registradas, start=1):
            idx_vehiculo = g.get('asignado_a_idx', -1)
            asignado_a_texto = "No asignado"
            if 0 <= idx_vehiculo < len(self.vehiculos_registrados):
                vehiculo = self.vehiculos_registrados[idx_vehiculo]
                asignado_a_texto = f"Vehículo {idx_vehiculo + 1} ({vehiculo['placa']})"
            
            self.gruas_tree.insert("", "end", iid=i-1, values=(f"{i}", g['tipo'], g['placa'], asignado_a_texto))
    # --- FIN CAMBIO ---

    # --- INICIO CAMBIO: Métodos para Ajustadores ---
    def agregar_ajustador(self):
        AjustadorPopup(self, callback=self.actualizar_lista_ajustadores)

    def editar_ajustador(self):
        seleccion = self.ajustadores_tree.focus()
        if not seleccion:
            messagebox.showwarning("Sin selección", "Por favor, selecciona un ajustador de la lista para editar.")
            return
        index = int(seleccion)
        ajustador_data = self.ajustadores_registrados[index]
        AjustadorPopup(self, callback=self.actualizar_lista_ajustadores, ajustador_data=ajustador_data, index=index)
    
    def eliminar_ajustador(self):
        seleccion = self.ajustadores_tree.focus()
        if not seleccion:
            messagebox.showwarning("Sin selección", "Por favor, selecciona un ajustador de la lista para eliminar.")
            return
        if messagebox.askyesno("Confirmar", "¿Estás seguro de que deseas eliminar el ajustador seleccionado?"):
            index = int(seleccion)
            self.ajustadores_registrados.pop(index)
            self.actualizar_lista_ajustadores()

    def actualizar_lista_ajustadores(self):
        for i in self.ajustadores_tree.get_children():
            self.ajustadores_tree.delete(i)
        for i, a in enumerate(self.ajustadores_registrados, start=1):
            idx_vehiculo = a.get('asignado_a_idx', -1)
            asignado_a_texto = "No asignado"
            if 0 <= idx_vehiculo < len(self.vehiculos_registrados):
                vehiculo = self.vehiculos_registrados[idx_vehiculo]
                asignado_a_texto = f"Vehículo {idx_vehiculo + 1} ({vehiculo['placa']})"
            
            self.ajustadores_tree.insert("", "end", iid=i-1, values=(f"{i}", a['nombre'], a['empresa'], asignado_a_texto))
    # --- FIN CAMBIO ---

    # --- MÉTODOS DE GENERACIÓN Y LIMPIEZA ---
    def generar_mensaje_encargado_click(self):
        try:
            # --- INICIO CAMBIO: Validación de fecha ---
            self.fecha.get_date()
            # --- FIN CAMBIO ---
            data = self.recolectar_datos("encargado")
            mensaje = self.generar_mensaje_encargado(data)
            ResultadoWindow(self, "Mensaje para Encargado", mensaje)
        except ValueError:
            messagebox.showerror("Error de Fecha", "El formato de la fecha es incorrecto. Por favor, usa dd/mm/aaaa.")
        except Exception as e:
            messagebox.showerror("Error", f"Error al generar mensaje: {str(e)}")

    def generar_mensaje_general_click(self):
        try:
            # --- INICIO CAMBIO: Validación de fecha ---
            self.fecha.get_date()
            # --- FIN CAMBIO ---
            data = self.recolectar_datos("general")
            mensaje = self.generar_mensaje_general(data)
            ResultadoWindow(self, "Mensaje General", mensaje)
        except ValueError:
            messagebox.showerror("Error de Fecha", "El formato de la fecha es incorrecto. Por favor, usa dd/mm/aaaa.")
        except Exception as e:
            messagebox.showerror("Error", f"Error al generar mensaje: {str(e)}")

    def limpiar_formulario(self):
        if not messagebox.askyesno("Limpiar", "¿Está seguro de que desea limpiar todos los campos?"):
            return
        
        self.fecha.set_date(datetime.now().date())
        self.hora_var.set("06")
        self.minuto_var.set("00")
        self.sede_entry.set("")
        self.unidad_entry.set("")
        self.ruta_entry.set("")
        self.jurisdiccion_entry.delete(0, tk.END)
        self.brigada_entry.delete(0, tk.END)
        self.km_entry1.delete(0, tk.END)
        self.km_rango_var.set(False) # Desmarca la casilla
        self._toggle_km_rango()      # Oculta el segundo campo
        self.tipo_var.set("")
        
        for var in self.autoridades_vars.values(): var.set(False)
        for var in self.socorro_vars.values(): var.set(False)
        self.authority_detail_widgets.clear()
        self.socorro_detail_widgets.clear()
        
        self.danios_materiales_var.set(False)
        self.danios_infraestructura_var.set(False)
        
        # --- INICIO CAMBIO: Limpieza de nuevas listas ---
        self.vehiculos_registrados.clear()
        self.gruas_registradas.clear()
        self.ajustadores_registrados.clear()
        self.actualizar_lista_vehiculos()
        self.actualizar_lista_gruas()
        self.actualizar_lista_ajustadores()
        # --- FIN CAMBIO ---

        self.observaciones_text.delete("1.0", tk.END)
        self.obstruccion_frame.sentido_cb.set("")
        self.obstruccion_frame.ambos_var.set(False)
        self.obstruccion_frame._reiniciar()
        for widget in self.opciones_frame.winfo_children(): widget.destroy()
        messagebox.showinfo("Limpiar", "Formulario limpiado correctamente")

   # Dentro de la clase ProvialApp...

    # --- REEMPLAZA ESTA FUNCIÓN COMPLETA ---

    # --- REEMPLAZA ESTE MÉTODO COMPLETO ---
    def recolectar_datos(self, tipo):
        if not self.tipo_var.get():
            messagebox.showwarning("Dato Faltante", "Por favor, selecciona un tipo de hecho (tránsito, asistencia o emergencia).")
            return None

        # --- LÓGICA CORREGIDA PARA OBTENER LA DIRECCIÓN ---
        sentidos_activos = self.obstruccion_frame.sentidos.keys()
        if sentidos_activos:
            # Une los sentidos activos, ej: "Norte, Sur"
            direccion_texto = ", ".join(sentidos_activos).capitalize()
        else:
            direccion_texto = "" # Se queda vacío si no se define obstrucción
        
        # --- (El resto de la función sigue igual, pero la incluyo para que sea un solo bloque) ---
        autoridades_detalles_cap = {}
        for name, widget_info in self.authority_detail_widgets.items():
            details = {label: cap_first(var.get()) for label, var in widget_info['vars'].items()}
            autoridades_detalles_cap[name] = details

        socorro_detalles_cap = {}
        for name, widget_info in self.socorro_detail_widgets.items():
            details = {label: cap_first(var.get()) for label, var in widget_info['vars'].items()}
            socorro_detalles_cap[name] = details

        def capitalizar_lista_de_dicts(lista):
            for item in lista:
                for key, value in item.items():
                    if isinstance(value, str):
                        item[key] = cap_first(value)
            return lista

        vehiculos_cap = capitalizar_lista_de_dicts(self.vehiculos_registrados)
        gruas_cap = capitalizar_lista_de_dicts(self.gruas_registradas)
        ajustadores_cap = capitalizar_lista_de_dicts(self.ajustadores_registrados)

        km1 = self.km_entry1.get()
        km2 = self.km_entry2.get()
        km_texto = ""
        if self.km_rango_var.get() and km1 and km2:
            km_texto = f"del {km1} al {km2}"
        elif km1:
            km_texto = km1

        data = {
            'fecha': self.fecha.get(),
            'hora': f"{self.hora_var.get()}:{self.minuto_var.get()}",
            'unidad': self.unidad_entry.get(),
            'sede': cap_first(self.sede_entry.get()),
            'ubicacion': f"Km {km_texto} Ruta {self.ruta_entry.get()}",
            'direccion': direccion_texto, # <--- USA LA VARIABLE CORREGIDA
            'jurisdiccion': cap_first(self.jurisdiccion_entry.get()),
            'brigada': cap_first(self.brigada_entry.get()),
            'obstruccion': cap_first(self.obstruccion_frame.obtener_descripcion()),
            'vehiculos': vehiculos_cap,
            'gruas': gruas_cap,
            'ajustadores': ajustadores_cap,
            'danios_materiales': self.danios_materiales_var.get(),
            'danios_infraestructura': self.danios_infraestructura_var.get(),
            'danios_infraestructura_desc': cap_first(self.infra_damage_entry.get()) if self.danios_infraestructura_var.get() else "",
            'autoridades_detalles': autoridades_detalles_cap,
            'socorro_detalles': socorro_detalles_cap,
            'autoridades': [auth for auth, var in self.autoridades_vars.items() if var.get()],
            'socorro': [socorro for socorro, var in self.socorro_vars.items() if var.get()]
        }
        
        tipo_principal = self.tipo_var.get()
        tipo_especifico = ""
        if self.tipo_especifico_entry:
            tipo_especifico = self.tipo_especifico_entry.get()
        
        if tipo_especifico:
            data['tipo_hecho'] = f"*{cap_first(tipo_principal)}:* {cap_first(tipo_especifico)}"
        else: 
            data['tipo_hecho'] = cap_first(tipo_principal)
        
        data['heridos'] = sum(1 for v in self.vehiculos_registrados if v.get('estado_piloto') == 'Herido')
        data['trasladados'] = sum(1 for v in self.vehiculos_registrados if v.get('estado_piloto') == 'Trasladado')
        data['fallecidos'] = sum(1 for v in self.vehiculos_registrados if v.get('estado_piloto') == 'Fallecido')

        if tipo == "encargado":
            data['observaciones'] = cap_first(self.observaciones_text.get("1.0", "end").strip())

        return data
    
    # Dentro de la clase ProvialApp...

    # --- REEMPLAZA ESTE MÉTODO COMPLETO ---
# Dentro de la clase ProvialApp...

    # --- REEMPLAZA ESTE MÉTODO COMPLETO ---
    def generar_mensaje_encargado(self, data: dict) -> str:
        fecha = data.get('fecha', datetime.now().strftime("%d/%m/%Y"))

        mensaje = f"""*Dirección General de Protección y Seguridad Vial -PROVIAL*

*Fecha* {fecha}
*Unidad* {data.get('unidad', 'N/A')}
*Sede {data.get('sede', 'N/A')}*

*Ubicación* {data.get('ubicacion', 'N/A')}
*Dirección* {data.get('direccion') or 'No especificada'}

*Brigada que reporta:* {data.get('brigada', 'N/A')}
*Jurisdicción* {data.get('jurisdiccion', 'N/A')}
{data.get('tipo_hecho', 'N/A')}
*Obstruye* {data.get('obstruccion', 'N/A')}"""

        vehiculos = data.get("vehiculos", [])
        if vehiculos:
            mensaje += f"\n\n*Cantidad de vehículos {len(vehiculos)}*"
            for i, v in enumerate(vehiculos, start=1):
                mensaje += f"""

*Vehículo {i}*
*Tipo* {v.get('tipo', 'N/A')}
*Color* {v.get('color', 'N/A')}
*Marca* {v.get('marca', 'N/A')}
*Placas* {v.get('placa', 'N/A')}
*Piloto* {v.get('estado_piloto', 'N/A')}"""
                if v.get('cargado') == 'Sí' and v.get('carga_tipo'):
                    mensaje += f"\n*Cargado con:* {v.get('carga_tipo')}"
        
        autoridades = ', '.join(data.get('autoridades', [])) or 'Ninguna'
        socorro = ', '.join(data.get('socorro', [])) or 'Ninguna'
        
        danios_materiales_txt = 'Sí' if data.get('danios_materiales') else 'No'
        infra_damage_text = "No"
        if data.get('danios_infraestructura'):
            desc = data.get('danios_infraestructura_desc')
            infra_damage_text = f"Sí, {desc}" if desc else "Sí"
        
        mensaje += f"""

*Autoridades presentes* {autoridades}
*Unidades de socorro* {socorro}

*Daños materiales:* {danios_materiales_txt}
*Daños a la infraestructura:* {infra_damage_text}

*Observaciones:* {data.get('observaciones', 'Sin observaciones')}"""
        
        return mensaje.strip()
    
    
    # --- INICIO CAMBIO: Lógica de mensaje general reestructurada ---
# Dentro de la clase ProvialApp...

    # --- REEMPLAZA ESTE MÉTODO COMPLETO ---
# Dentro de la clase ProvialApp...

    # --- REEMPLAZA ESTE MÉTODO COMPLETO ---
# Dentro de la clase ProvialApp...

    # --- REEMPLAZA ESTE MÉTODO COMPLETO ---
    def generar_mensaje_general(self, data: dict) -> str:
        autoridades_texto = ', '.join(data.get('autoridades', [])) or 'Ninguna'
        socorro_texto = ', '.join(data.get('socorro', [])) or 'Ninguna'
        
        danios_materiales_txt = 'Sí' if data.get('danios_materiales') else 'No'
        infra_damage_text = "No"
        if data.get('danios_infraestructura'):
            desc = data.get('danios_infraestructura_desc')
            infra_damage_text = f"Sí, {desc}" if desc else "Sí"
        
        mensaje = f"""{data.get('hora', 'HH:MM')} Se Reporta Novedad En El {data.get('ubicacion', 'N/A')}

{data.get('tipo_hecho', 'N/A')}
Brigada que reporta: {data.get('brigada', 'N/A')}
Jurisdicción: {data.get('jurisdiccion', 'N/A')}
Carril obstruido: {data.get('obstruccion', 'N/A')}
Heridos: {data.get('heridos', 0)}
Trasladados: {data.get('trasladados', 0)}
Fallecidos: {data.get('fallecidos', 0)}
Autoridades presentes: {autoridades_texto}
Unidades de socorro: {socorro_texto}
Daños Materiales: {danios_materiales_txt}
Daños a la infraestructura: {infra_damage_text}"""

        if data.get('autoridades_detalles'):
            for name, details in data['autoridades_detalles'].items():
                mensaje += f"\n\n--- Datos {name} ---"
                for label, value in details.items():
                    if value: 
                        mensaje += f"\n{label}: {value}"

        if data.get('socorro_detalles'):
            for name, details in data['socorro_detalles'].items():
                mensaje += f"\n\n--- Datos {name} ---"
                for label, value in details.items():
                    if value:
                        mensaje += f"\n{label}: {value}"

        for i, v in enumerate(data.get('vehiculos', []), start=1):
            mensaje += f"""

******Vehículo {i}******
Tipo de vehículo: {v.get('tipo', 'N/A')}
Marca: {v.get('marca', 'N/A')}
Color: {v.get('color', 'N/A')}
Placas: {v.get('placa', 'N/A')}
Piloto: {v.get('estado_piloto', 'N/A')}"""
            
            if v.get('cargado') == 'Sí' and v.get('carga_tipo'):
                mensaje += f"\nCargado con: {v.get('carga_tipo')}"

            mensaje += f"""

--- Datos de Piloto/Vehículo ---
TC: {v.get('tarjeta', 'N/A')}
Nit: {v.get('nit', 'N/A')}
Dirección: {v.get('direccion', 'N/A')}
Propietario: {v.get('propietario', 'N/A')}
Modelo: {v.get('modelo', 'N/A')}

Piloto: {v.get('nombre_piloto', 'N/A')}
Lic tipo: {v.get('tipo_licencia', 'N/A')}
Numero: {v.get('numero_licencia', 'N/A')}
Antigüedad: {v.get('antiguedad', 'N/A')} años
Vigencia: {v.get('vencimiento', 'N/A')}
Etnia: {v.get('etnia', 'N/A')}
Edad: {v.get('edad', 'N/A')} Años
Personas Asistidas: {v.get('asistidas', 0)}"""

            if v.get('contenedor') == 'Sí' or v.get('doble_remolque') == 'Sí':
                mensaje += f"""

--- Detalles de Contenedor ---
TC: {v.get('cont_TC del Contenedor', 'N/A')}
Placa: {v.get('cont_Placa Contenedor', 'N/A')}
Propietario: {v.get('cont_Propietario', 'N/A')}
Dirección: {v.get('cont_Dirección', 'N/A')}
Empresa: {v.get('cont_Empresa', 'N/A')}
Modelo: {v.get('cont_Modelo', 'N/A')}"""
            
            if v.get('doble_remolque') == 'Sí':
                mensaje += f"""
Ejes: {v.get('cont_Ejes', 'N/A')}
Calcomanía: {v.get('cont_Calcomanía', 'N/A')}
Longitud: {v.get('cont_Longitud', 'N/A')}"""

            if v.get('bus_extraurbano') == 'Sí':
                mensaje += f"""

--- Datos de Bus Extraurbano ---
Lic. Operaciones: {v.get('bus_No. de Lic. de Operaciones', 'N/A')} (Vence: {v.get('bus_Fecha de Vencimiento de Lic. de Operaciones', 'N/A')})
Tarj. Operaciones: {v.get('bus_No. de Tarjeta de Operaciones', 'N/A')} (Vence: {v.get('bus_Fecha de Vencimiento de Tarjeta de Operaciones', 'N/A')})
Seguro: {v.get('bus_Nombre del Seguro', 'N/A')}
No. Póliza: {v.get('bus_No. Seguro', 'N/A')} (Vence: {v.get('bus_Fecha de Vencimiento del Seguro', 'N/A')})
Ruta Autorizada: {v.get('bus_Ruta Autorizada', 'N/A')}"""

            if v.get('sancion') == 'Sí':
                mensaje += f"""

--- Sánción Impuesta ---
No. Artículo: {v.get('sancion_No. Artículo', 'N/A')}
Motivo: {v.get('sancion_Motivo', 'N/A')}
Quien la impuso: {v.get('sancion_Quien la impuso', 'N/A')}
No. de Boleta: {v.get('sancion_No. de Boleta', 'N/A')}"""

        # --- ESTE ES EL BLOQUE QUE FALTABA ---
        for i, g in enumerate(data.get('gruas', [])):
            if g.get('asignado_a_idx', -1) >= 0:
                mensaje += f"""

--- Grúa del Vehículo {g.get('asignado_a_idx') + 1} ---
Tipo: {g.get('tipo', 'N/A')} - Placa: {g.get('placa', 'N/A')}
Empresa: {g.get('empresa', 'N/A')} - Piloto: {g.get('piloto', 'N/A')}"""
                if g.get('traslado') == 'Sí':
                    mensaje += f"\nTrasladado a: {g.get('traslado_a', 'N/A')}"

        for i, a in enumerate(data.get('ajustadores', [])):
             if a.get('asignado_a_idx', -1) >= 0:
                mensaje += f"""

--- Ajustador del Vehículo {a.get('asignado_a_idx') + 1} ---
Nombre: {a.get('nombre', 'N/A')} - Empresa: {a.get('empresa', 'N/A')}
Vehículo: {a.get('tipo_vehiculo', '')} {a.get('marca', '')} placas {a.get('placa', 'N/A')}"""
        
        # También se incluyen los no asignados al final
        extras = [g for g in data.get('gruas', []) if g.get('asignado_a_idx', -1) < 0] + \
                 [a for a in data.get('ajustadores', []) if a.get('asignado_a_idx', -1) < 0]
        if extras:
            mensaje += "\n\n--- Datos Extras (Sin Asignar) ---"
            for item in extras:
                if 'piloto' in item: # Es una grúa
                    mensaje += f"\nGrúa: {item.get('tipo','')} placas {item.get('placa','')} de empresa {item.get('empresa','')}"
                else: # Es un ajustador
                    mensaje += f"\nAjustador: {item.get('nombre','')} de empresa {item.get('empresa','')}"

        return mensaje.strip()

# --- REEMPLAZA ESTA CLASE COMPLETA ---
class ObstruccionFrame(ttk.LabelFrame):
    def __init__(self, master):
        super().__init__(master, text="Obstrucción Vial")
        self.sentidos = {}
        self.resultado_var = tk.StringVar()

        ttk.Label(self, text="Dirección principal:").pack(anchor="center")
        self.sentido_cb = ttk.Combobox(self, values=["Norte", "Sur", "Oriente", "Occidente"])
        self.sentido_cb.pack(anchor="center", pady=2)
        self.sentido_cb.bind("<<ComboboxSelected>>", self._reiniciar)

        self.ambos_var = tk.BooleanVar()
        self.ambos_chk = ttk.Checkbutton(self, text="¿Ambos sentidos?", 
                                         variable=self.ambos_var, command=self._reiniciar)
        self.ambos_chk.pack(anchor="center")

        self.sentidos_frame = ttk.Frame(self)
        self.sentidos_frame.pack(fill="x", pady=5)

    def _reiniciar(self, *args):
        for widget in self.sentidos_frame.winfo_children():
            widget.destroy()
        self.sentidos.clear()

        principal = self.sentido_cb.get()
        if not principal:
            self._actualizar_resultado() # Actualiza por si se borra la selección
            return

        activos = [principal]
        if self.ambos_var.get():
            opuestos = {"Norte": "Sur", "Sur": "Norte", "Oriente": "Occidente", "Occidente": "Oriente"}
            if principal in opuestos:
                activos.append(opuestos[principal])

        for sentido in activos:
            frame = SentidoFrame(self.sentidos_frame, sentido, self._actualizar_resultado)
            frame.pack(fill="x", padx=5, pady=5)
            self.sentidos[sentido] = frame

        self._actualizar_resultado()

# Dentro de la clase ObstruccionFrame...

    # --- REEMPLAZA ESTE MÉTODO COMPLETO ---
    def _actualizar_resultado(self):
        partes = []
        for sentido, frame in self.sentidos.items():
            # Caso 1: El vehículo está fuera de la vía
            if frame.fuera_via_var.get():
                partes.append(f"un vehículo fuera de la vía con sentido hacia el {sentido.lower()}")
                continue

            carriles = frame.obtener_obstrucciones()
            if not carriles:
                continue

            # Caso 2: La vía es de un solo carril
            if frame.un_carril_var.get():
                porcentaje = carriles[0]['porcentaje']
                texto_final_sentido = f"{porcentaje}% del carril con sentido hacia el {sentido.lower()}"
            
            # Caso 3: La vía tiene múltiples carriles (comportamiento detallado)
            else:
                if len(carriles) == 1:
                    c = carriles[0]
                    texto_carriles = f"el carril {c['tipo'].lower()} obstruido en un {c['porcentaje']}%"
                else:
                    lista = [f"el {c['tipo'].lower()} ({c['porcentaje']}%)" for c in carriles]
                    texto_carriles = f"los carriles {', '.join(lista[:-1])} y {lista[-1]} obstruidos"
                
                texto_final_sentido = f"{texto_carriles} con sentido hacia el {sentido.lower()}"
            
            partes.append(texto_final_sentido)
        
        resultado_final = "; ".join(partes) if partes else "Sin obstrucciones registradas."
        self.resultado_var.set(resultado_final.capitalize())
        
    def obtener_descripcion(self):
        return self.resultado_var.get()
# --- REEMPLAZA ESTA CLASE COMPLETA ---
class SentidoFrame(ttk.LabelFrame):
    def __init__(self, master, sentido, callback):
        super().__init__(master, text=f"Sentido {sentido}")
        self.sentido = sentido
        self.callback = callback
        self.carriles = {}

        chk_frame = ttk.Frame(self)
        chk_frame.pack(pady=3)

        self.fuera_via_var = tk.BooleanVar()
        fuera_via_chk = ttk.Checkbutton(chk_frame, text="Fuera de la vía", 
                                        variable=self.fuera_via_var, command=self._toggle_fuera_via)
        fuera_via_chk.pack(side="left", padx=5)

        self.un_carril_var = tk.BooleanVar()
        un_carril_chk = ttk.Checkbutton(chk_frame, text="Es de un solo carril",
                                        variable=self.un_carril_var, command=self.callback)
        un_carril_chk.pack(side="left", padx=5)

        self.inner_frame = ttk.Frame(self)
        self.inner_frame.pack(fill="x", padx=5, pady=2)

        self.btn_agregar = ttk.Button(self, text="Agregar carril obstruido", command=self.agregar_carril)
        self.btn_agregar.pack(pady=3)

    def _toggle_fuera_via(self):
        if self.fuera_via_var.get():
            self.btn_agregar.config(state="disabled")
            for tipo in list(self.carriles.keys()):
                self.eliminar(tipo, refrescar=False)
            self._refrescar()
        else:
            self.btn_agregar.config(state="normal")
        self.callback()

    def agregar_carril(self):
        if self.un_carril_var.get() and len(self.carriles) >= 1:
            messagebox.showinfo("Límite Alcanzado", "En una vía de un solo carril, solo puedes registrar una obstrucción.")
            return

        if len(self.carriles) >= 3:
            messagebox.showinfo("Límite", "Solo se permiten 3 carriles: izquierdo, central y derecho")
            return

        if any(isinstance(child, tk.Toplevel) for child in self.winfo_children()):
            return 
        
        popup = CarrilPopup(self, self.carriles.keys())
        self.wait_window(popup)

        if popup.result:
            tipo, porcentaje = popup.result
            self.carriles[tipo] = {'tipo': tipo, 'porcentaje': porcentaje}
            self._refrescar()
            self.callback()

    def _refrescar(self):
        for widget in self.inner_frame.winfo_children(): widget.destroy()
        for tipo, datos in self.carriles.items():
            frame = ttk.Frame(self.inner_frame)
            frame.pack(fill="x")
            ttk.Label(frame, text=f"{tipo}: {datos['porcentaje']}%").pack(side="left")
            btn = ttk.Button(frame, text="Eliminar", command=lambda t=tipo: self.eliminar(t))
            btn.pack(side="right")

    def eliminar(self, tipo, refrescar=True):
        if tipo in self.carriles:
            del self.carriles[tipo]
            if refrescar:
                self._refrescar()
                self.callback()

    def obtener_obstrucciones(self):
        return list(self.carriles.values())
    
class CarrilPopup(tk.Toplevel):
    def __init__(self, master, existentes):
        super().__init__(master)
        self.title("Agregar carril")
        self.geometry("300x150")
        self.resizable(False, False)
        self.result = None

        self.transient(master)
        self.grab_set()
        
        self.update_idletasks()
        x = master.winfo_rootx() + (master.winfo_width() // 2) - (self.winfo_width() // 2)
        y = master.winfo_rooty() + (master.winfo_height() // 2) - (self.winfo_height() // 2)
        self.geometry(f"+{x}+{y}")

        opciones = ["Izquierdo", "Central", "Derecho"]
        disponibles = [op for op in opciones if op not in existentes]
        if not disponibles:
            self.destroy()
            return

        ttk.Label(self, text="Tipo de carril").pack(pady=5)
        self.tipo_var = tk.StringVar(value=disponibles[0])
        ttk.Combobox(self, textvariable=self.tipo_var, values=disponibles, ).pack()

        ttk.Label(self, text="Porcentaje de obstrucción (1-100)").pack(pady=5)
        self.porc_var = tk.StringVar()
        porc_entry = ttk.Entry(self, textvariable=self.porc_var)
        porc_entry.pack()

        ttk.Button(self, text="Aceptar", command=self.aceptar).pack(pady=10)

    def aceptar(self):
        try:
            porc = int(self.porc_var.get())
            if not (1 <= porc <= 100): raise ValueError
            self.result = (self.tipo_var.get(), porc)
            self.destroy()
        except ValueError:
            messagebox.showerror("Error", "Ingresa un porcentaje entre 1 y 100", parent=self)

# (Clase VehiculoPopup permanece sin cambios)
# === Popup de vehículo ===
class VehiculoPopup(tk.Toplevel):
    def __init__(self, app_instance, callback, vehiculo_data=None, index=None):
        super().__init__(app_instance)
        self.app = app_instance
        self.callback = callback
        self.vehiculo_data = vehiculo_data
        self.index = index
        
        self.title("Datos del Vehículo")
        if self.vehiculo_data:
            self.title("Editar Datos del Vehículo")

        self.geometry("520x750")
        # --- CORRECCIÓN: Se permite cambiar el tamaño de la ventana ---
        self.resizable(True, True) 
        self.minsize(450, 600) # Se establece un tamaño mínimo razonable
        
        # Layout principal para que el canvas se expanda
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(0, weight=1)

        canvas = tk.Canvas(self, borderwidth=0)
        scrollbar = ttk.Scrollbar(self, orient="vertical", command=canvas.yview)
        self.scroll_frame = ttk.Frame(canvas)
        self.scroll_frame.grid_columnconfigure(0, weight=1)
        canvas.create_window((0, 0), window=self.scroll_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        
        canvas.grid(row=0, column=0, sticky="nsew")
        scrollbar.grid(row=0, column=1, sticky="ns")
        
        def on_configure(event):
            canvas.configure(scrollregion=canvas.bbox("all"))
            canvas.itemconfigure(canvas.find_all()[0], width=canvas.winfo_width())
        self.scroll_frame.bind("<Configure>", on_configure)

        def on_popup_mousewheel(event):
            canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")
        self.bind("<MouseWheel>", on_popup_mousewheel)

        self.widget_frame = ttk.Frame(self.scroll_frame)
        self.widget_frame.grid(row=0, column=0, sticky="ew")
        self.widget_frame.grid_columnconfigure(0, weight=1)

        self._crear_widgets_principales()
        self._crear_widgets_condicionales()
        
        if self.vehiculo_data:
            self.llenar_formulario()
        
        self._actualizar_campos_condicionales()
        
        ttk.Button(self.widget_frame, text="Guardar", command=self.guardar).grid(pady=20, column=0)
        
        self.transient(app_instance)
        self.grab_set()
        self.focus_set()

    def _agregar_widget(self, container, label_text, widget):
        row = container.grid_size()[1]
        ttk.Label(container, text=label_text).grid(row=row, column=0, sticky="w", padx=5, pady=(5,0))
        widget.grid(row=row + 1, column=0, sticky="ew", padx=5, pady=(0,5))

    def _crear_widgets_principales(self):
        main_frame = ttk.LabelFrame(self.widget_frame, text="Datos Principales del Vehículo")
        main_frame.grid(sticky="ew", padx=10, pady=5, column=0)
        main_frame.grid_columnconfigure(0, weight=1)

        self.tipo_entry = SearchableEntry(main_frame, 
                                  values=sorted(["Motocicleta", "Jaula Cañera", "Rastra", "Bicicleta", "Jeep", "Bus escolar", "Maquinaria", "Bus turismo", "Tractor", "Ambulancia", "Camionetilla", "Pulman", "Autopatrulla PNC", "Bus extraurbano", "Bus urbano", "Camioneta agricola", "Cisterna", "Furgon", "Mototaxi", "Microbus", "Motobicicleta", "Plataforma", "Panel", "Unidad de PROVIAL", "Grúa", "Bus institucional", "Cuatrimoto", "Doble remolque", "Tesla", "Peaton", "Fugado", "Sedan", "Pick-up", "Camión", "Bus", "Cabezal","Otro"]),
                                  keyrelease_callback=self._actualizar_campos_condicionales)
        self._agregar_widget(main_frame, "Tipo de vehículo", self.tipo_entry)
        
        self.color_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "Color", self.color_entry)
        
        self.marca_entry = SearchableEntry(main_frame, values=sorted(["Toyota", "Honda", "Nissan", "Jeep", "BMW", "Mitsubishi", "Suzuki", "Hyundai", "Mazda", "Chevrolet", "Freightliner", "International", "Volvo", "Italika", "Kia", "Volkswagen", "Ford", "Audi", "JAC", "Hino", "Otro"]))
        self._agregar_widget(main_frame, "Marca", self.marca_entry)
        
        placa_frame = ttk.Frame(main_frame)
        placa_frame.grid(row=main_frame.grid_size()[1], column=0, sticky="w", padx=5, pady=(5,5))
        ttk.Label(placa_frame, text="Placa").pack(side="left")
        self.placa_entry = ttk.Entry(placa_frame)
        self.placa_entry.pack(side="left", padx=5)
        self.extranjera_var = tk.BooleanVar()
        ttk.Checkbutton(placa_frame, text="Extranjera", variable=self.extranjera_var).pack(side="left")

        self.estado_entry = SearchableEntry(main_frame, values=["Ileso", "Herido", "Trasladado", "Fallecido", "Fugado", "Consignado"])
        self._agregar_widget(main_frame, "Estado del piloto", self.estado_entry)
        self.asistidas_spin = tk.Spinbox(main_frame, from_=0, to=20, width=5)
        self._agregar_widget(main_frame, "Personas asistidas", self.asistidas_spin)
        self.tarjeta_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "No. de tarjeta de circulación", self.tarjeta_entry)
        self.nit_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "NIT", self.nit_entry)
        self.dir_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "Dirección del propietario", self.dir_entry)
        self.prop_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "Nombre del propietario", self.prop_entry)
        
        self.modelo_entry = SearchableEntry(main_frame, values=[str(a) for a in range(1980, 2026)])
        self._agregar_widget(main_frame, "Modelo del vehículo (año)", self.modelo_entry)
        self.nombre_piloto_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "Nombre del piloto", self.nombre_piloto_entry)
        self.tipo_lic_entry = SearchableEntry(main_frame, values=["Tipo A", "Tipo B", "Tipo C", "Tipo M", "Extranjera", "Otra"])
        self._agregar_widget(main_frame, "Tipo de licencia", self.tipo_lic_entry)
        
        self.num_lic_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "No. de licencia", self.num_lic_entry)
        self.venc_lic_entry = DateEntry(main_frame, date_pattern="dd/mm/yyyy")
        self._agregar_widget(main_frame, "Vencimiento de la licencia", self.venc_lic_entry)
        self.antig_lic_spin = tk.Spinbox(main_frame, from_=0, to=50, width=5)
        self._agregar_widget(main_frame, "Antigüedad de la licencia (años)", self.antig_lic_spin)
        self.nac_piloto_entry = DateEntry(main_frame, date_pattern="dd/mm/yyyy")
        self._agregar_widget(main_frame, "Fecha de nacimiento del piloto", self.nac_piloto_entry)
        self.etnia_entry = SearchableEntry(main_frame, values=["Ladina", "Maya", "Garífuna", "Xinca", "Extranjero", "Otra"])
        self._agregar_widget(main_frame, "Etnia del piloto", self.etnia_entry)
        

    def _crear_widgets_condicionales(self):
        self.condicional_frame = ttk.Frame(self.widget_frame)
        self.condicional_frame.grid(sticky="ew", column=0, padx=10, pady=5)
        self.condicional_frame.grid_columnconfigure(0, weight=1)

        # 1. Frame de Carga
        self.carga_frame = ttk.LabelFrame(self.condicional_frame, text="Detalles de Carga")
        self.cargado_var = tk.StringVar(value="No")
        cargado_cb = ttk.Combobox(self.carga_frame, textvariable=self.cargado_var, values=["Sí", "No"], state="readonly")
        self._agregar_widget(self.carga_frame, "¿Vehículo cargado?", cargado_cb)
        self.cargado_var.trace_add("write", self._actualizar_campos_condicionales)
        self.carga_tipo_entry = ttk.Entry(self.carga_frame)

        # 2. Frame de Contenedor/Remolque
        self.contenedor_frame = ttk.LabelFrame(self.condicional_frame, text="Detalles de Contenedor / Remolque")
        self.contenedor_var = tk.StringVar(value="No")
        self.doble_remolque_var = tk.StringVar(value="No")
        contenedor_cb = ttk.Combobox(self.contenedor_frame, textvariable=self.contenedor_var, values=["Sí", "No"], state="readonly")
        self._agregar_widget(self.contenedor_frame, "¿Contenedor?", contenedor_cb)
        self.contenedor_var.trace_add("write", self._actualizar_campos_condicionales)
        
        self.cont_widgets = {
            "TC del Contenedor": ttk.Entry(self.contenedor_frame), 
            "Placa Contenedor": ttk.Entry(self.contenedor_frame),
            "Modelo": ttk.Entry(self.contenedor_frame), 
            "Propietario": ttk.Entry(self.contenedor_frame),
            "Dirección": ttk.Entry(self.contenedor_frame), 
            "Empresa": ttk.Entry(self.contenedor_frame),
            "Ejes": ttk.Entry(self.contenedor_frame), 
            "Calcomanía": ttk.Entry(self.contenedor_frame),
            "Longitud": ttk.Entry(self.contenedor_frame)
        }
        
        self.doble_remolque_cb = ttk.Combobox(self.contenedor_frame, textvariable=self.doble_remolque_var, values=["Sí", "No"], state="readonly")
        self.doble_remolque_var.trace_add("write", self._actualizar_campos_condicionales)

        # 3. Frame de Bus Extraurbano
        self.bus_frame = ttk.LabelFrame(self.condicional_frame, text="Datos de Bus Extraurbano")
        self.bus_var = tk.StringVar(value="No")
        bus_cb = ttk.Combobox(self.bus_frame, textvariable=self.bus_var, values=["Sí", "No"], state="readonly")
        self._agregar_widget(self.bus_frame, "¿Bus Extraurbano?", bus_cb)
        self.bus_var.trace_add("write", self._actualizar_campos_condicionales)
        self.bus_widgets = {
            "No. de Lic. de Operaciones": ttk.Entry(self.bus_frame), 
            "Fecha de Vencimiento de Lic. de Operaciones": DateEntry(self.bus_frame, date_pattern="dd/mm/yyyy"),
            "No. de Tarjeta de Operaciones": ttk.Entry(self.bus_frame), 
            "Fecha de Vencimiento de Tarjeta de Operaciones": DateEntry(self.bus_frame, date_pattern="dd/mm/yyyy"),
            "Nombre del Seguro": ttk.Entry(self.bus_frame), 
            "No. Seguro": ttk.Entry(self.bus_frame),
            "Fecha de Vencimiento del Seguro": DateEntry(self.bus_frame, date_pattern="dd/mm/yyyy"),
            "Ruta Autorizada": ttk.Entry(self.bus_frame)
        }

        # 4. Frame de Sanción
        self.sancion_frame = ttk.LabelFrame(self.condicional_frame, text="Sanción Impuesta")
        self.sancion_var = tk.StringVar(value="No")
        sancion_cb = ttk.Combobox(self.sancion_frame, textvariable=self.sancion_var, values=["Sí", "No"], state="readonly")
        self._agregar_widget(self.sancion_frame, "¿Se impuso sanción?", sancion_cb)
        self.sancion_var.trace_add("write", self._actualizar_campos_condicionales)
        self.sancion_widgets = {
            "No. Artículo": ttk.Entry(self.sancion_frame),
            "Motivo": ttk.Entry(self.sancion_frame),
            "Quien la impuso": ttk.Entry(self.sancion_frame),
            "No. de Boleta": ttk.Entry(self.sancion_frame)
        }

    def _actualizar_campos_condicionales(self, *args):
        for frame in [self.carga_frame, self.contenedor_frame, self.bus_frame, self.sancion_frame]:
            for widget in frame.winfo_children():
                if not isinstance(widget, ttk.Combobox):
                    is_main_label = False
                    widget_info = widget.grid_info()
                    if widget.winfo_class() == 'TLabel' and widget_info:
                        row = widget_info.get('row', -1)
                        for cb in frame.winfo_children():
                            if isinstance(cb, ttk.Combobox):
                                cb_info = cb.grid_info()
                                if cb_info and cb_info.get('row', -1) == row + 1:
                                    is_main_label = True
                                    break
                    
                    if not is_main_label:
                        widget.grid_forget()

        self.carga_frame.grid_forget()
        self.contenedor_frame.grid_forget()
        self.bus_frame.grid_forget()
        self.sancion_frame.grid_forget()

        self.carga_frame.grid(row=0, column=0, sticky="ew", pady=5)
        if self.cargado_var.get() == "Sí":
            self._agregar_widget(self.carga_frame, "¿Con qué iba cargado?", self.carga_tipo_entry)

        self.contenedor_frame.grid(row=1, column=0, sticky="ew", pady=5)
        if self.contenedor_var.get() == "Sí":
            for label in ["TC del Contenedor", "Placa Contenedor", "Propietario", "Dirección", "Empresa", "Modelo"]:
                self._agregar_widget(self.contenedor_frame, label, self.cont_widgets[label])
            self._agregar_widget(self.contenedor_frame, "¿Doble Remolque?", self.doble_remolque_cb)
            if self.doble_remolque_var.get() == "Sí":
                for label in ["Ejes", "Calcomanía", "Longitud"]:
                    self._agregar_widget(self.contenedor_frame, label, self.cont_widgets[label])

        self.bus_frame.grid(row=2, column=0, sticky="ew", pady=5)
        if self.bus_var.get() == "Sí":
            for label, widget in self.bus_widgets.items():
                self._agregar_widget(self.bus_frame, label, widget)

        self.sancion_frame.grid(row=3, column=0, sticky="ew", pady=5)
        if self.sancion_var.get() == "Sí":
            for label, widget in self.sancion_widgets.items():
                self._agregar_widget(self.sancion_frame, label, widget)

    def llenar_formulario(self):
        data = self.vehiculo_data
        self.tipo_entry.set(data.get("tipo", ""))
        self.color_entry.insert(0, data.get("color", ""))
        self.marca_entry.set(data.get("marca", ""))
        placa_full = data.get("placa", "")
        if " (Extranjera)" in placa_full:
            self.placa_entry.insert(0, placa_full.replace(" (Extranjera)", ""))
            self.extranjera_var.set(True)
        else: self.placa_entry.insert(0, placa_full)
        self.estado_entry.set(data.get("estado_piloto", ""))
        self.asistidas_spin.delete(0, "end"); self.asistidas_spin.insert(0, data.get("asistidas", 0))
        self.tarjeta_entry.insert(0, data.get("tarjeta", ""))
        self.nit_entry.insert(0, data.get("nit", ""))
        self.dir_entry.insert(0, data.get("direccion", ""))
        self.prop_entry.insert(0, data.get("propietario", ""))
        self.modelo_entry.set(data.get("modelo", ""))
        self.nombre_piloto_entry.insert(0, data.get("nombre_piloto", ""))
        self.tipo_lic_entry.set(data.get("tipo_licencia", ""))
        self.num_lic_entry.insert(0, data.get("numero_licencia", ""))
        self.venc_lic_entry.set_date(data.get("vencimiento"))
        self.antig_lic_spin.delete(0, "end"); self.antig_lic_spin.insert(0, data.get("antiguedad", 0))
        self.nac_piloto_entry.set_date(data.get("nacimiento_piloto"))
        self.etnia_entry.set(data.get("etnia", ""))

        self.cargado_var.set(data.get("cargado", "No"))
        self.carga_tipo_entry.insert(0, data.get("carga_tipo", ""))
        self.sancion_var.set(data.get("sancion", "No"))
        self.bus_var.set(data.get("bus_extraurbano", "No"))
        self.contenedor_var.set(data.get("contenedor", "No"))
        self.doble_remolque_var.set(data.get("doble_remolque", "No"))
        for key, widget in self.sancion_widgets.items():
            if isinstance(widget, DateEntry): widget.set_date(data.get(f"sancion_{key}"))
            else: widget.insert(0, data.get(f"sancion_{key}", ""))
        for key, widget in self.bus_widgets.items():
            if isinstance(widget, DateEntry): widget.set_date(data.get(f"bus_{key}"))
            else: widget.insert(0, data.get(f"bus_{key}", ""))
        for key, widget in self.cont_widgets.items():
            widget.insert(0, data.get(f"cont_{key}", ""))

    def guardar(self):
        try:
            nac_date = self.nac_piloto_entry.get_date()
            edad = datetime.now().year - nac_date.year - ((datetime.now().month, datetime.now().day) < (nac_date.month, nac_date.day))
        except ValueError:
            messagebox.showwarning("Fecha Inválida", "La fecha de nacimiento no es válida. La edad se guardará como N/A.", parent=self)
            edad = self.vehiculo_data.get("edad", "N/A") if self.vehiculo_data else "N/A"

        vehiculo = {
            "tipo": self.tipo_entry.get(), "color": self.color_entry.get(), "marca": self.marca_entry.get(),
            "placa": f"{self.placa_entry.get()}{' (Extranjera)' if self.extranjera_var.get() else ''}",
            "estado_piloto": self.estado_entry.get(), "asistidas": self.asistidas_spin.get(),
            "tarjeta": self.tarjeta_entry.get(), "nit": self.nit_entry.get(),
            "direccion": self.dir_entry.get(), "propietario": self.prop_entry.get(),
            "modelo": self.modelo_entry.get(), "nombre_piloto": self.nombre_piloto_entry.get(),
            "tipo_licencia": self.tipo_lic_entry.get(), "numero_licencia": self.num_lic_entry.get(),
            "vencimiento": self.venc_lic_entry.get(), "antiguedad": self.antig_lic_spin.get(),
            "nacimiento_piloto": self.nac_piloto_entry.get(), "etnia": self.etnia_entry.get(), "edad": edad,
            "cargado": self.cargado_var.get(), "carga_tipo": self.carga_tipo_entry.get() if self.cargado_var.get() == "Sí" else "",
            "sancion": self.sancion_var.get(), "bus_extraurbano": self.bus_var.get(), 
            "contenedor": self.contenedor_var.get(), "doble_remolque": self.doble_remolque_var.get(),
        }
        if self.sancion_var.get() == "Sí":
            for label, widget in self.sancion_widgets.items(): vehiculo[f"sancion_{label}"] = widget.get()
        if self.bus_var.get() == "Sí":
            for label, widget in self.bus_widgets.items(): vehiculo[f"bus_{label}"] = widget.get()
        if self.contenedor_var.get() == "Sí" or self.doble_remolque_var.get() == "Sí":
             for label in ["TC del Contenedor", "Placa Contenedor", "Modelo", "Propietario", "Dirección", "Empresa"]: vehiculo[f"cont_{label}"] = self.cont_widgets[label].get()
        if self.doble_remolque_var.get() == "Sí":
            for label in ["Ejes", "Calcomanía", "Longitud"]: vehiculo[f"cont_{label}"] = self.cont_widgets[label].get()

        if self.index is not None:
            self.app.vehiculos_registrados[self.index] = vehiculo
        else:
            self.app.vehiculos_registrados.append(vehiculo)
        
        self.callback()
        self.destroy()
# --- FIN CAMBIO ---

# --- REEMPLAZA TU CLASE GruaPopup COMPLETA CON ESTA ---
class GruaPopup(tk.Toplevel):
    def __init__(self, app_instance, callback, grua_data=None, index=None):
        super().__init__(app_instance)
        self.app = app_instance
        self.callback = callback
        self.grua_data = grua_data
        self.index = index
        
        self.title("Datos de la Grúa" if not grua_data else "Editar Datos de la Grúa")
        self.geometry("400x550")
        self.resizable(False, False)

        main_frame = ttk.Frame(self)
        main_frame.pack(fill="both", expand=True, padx=10, pady=10)

        # --- Creación de todos los widgets ---
        tipos_grua = ["Plataforma", "Pluma", "Remolque", "Otro"]
        self.tipo_cb = ttk.Combobox(main_frame, values=tipos_grua)
        self._agregar_widget(main_frame, "Tipo de grúa", self.tipo_cb)
        
        self.color_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "Color", self.color_entry)
        
        self.marca_entry = SearchableEntry(main_frame, values=VEHICULO_MARCAS)
        self._agregar_widget(main_frame, "Marca", self.marca_entry)
        
        self.placa_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "Placa", self.placa_entry)
        
        self.empresa_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "Empresa", self.empresa_entry)
        
        self.piloto_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "Piloto", self.piloto_entry)
        
        opciones_vehiculos = {f"Vehículo {i+1} ({v['placa']})": i for i, v in enumerate(self.app.vehiculos_registrados)}
        opciones_vehiculos["No asignar"] = -1
        self.asignar_var = tk.StringVar(value="No asignar")
        self.asignar_cb = ttk.Combobox(main_frame, textvariable=self.asignar_var, values=list(opciones_vehiculos.keys()), state="readonly")
        self._agregar_widget(main_frame, "Asignar a vehículo", self.asignar_cb)
        self.opciones_vehiculos_map = opciones_vehiculos
        
        self.traslado_var = tk.StringVar(value="No")
        self.traslado_cb = ttk.Combobox(main_frame, textvariable=self.traslado_var, values=["Sí", "No"], state="readonly")
        self.traslado_cb.bind("<<ComboboxSelected>>", self._toggle_traslado_a)
        self._agregar_widget(main_frame, "¿Realizó traslado?", self.traslado_cb)

        # Widgets de traslado (se mostrarán u ocultarán)
        self.traslado_a_label = ttk.Label(main_frame, text="¿A dónde se trasladó?")
        self.traslado_a_entry = ttk.Entry(main_frame)

        if self.grua_data:
            self.llenar_formulario()
        
        self._toggle_traslado_a() # Llama a la función una vez para establecer el estado inicial

        # Botón de guardar
        ttk.Button(main_frame, text="Guardar", command=self.guardar).pack(pady=20)
        self.transient(app_instance); self.grab_set(); self.focus_set()

    def _agregar_widget(self, container, label, widget):
        ttk.Label(container, text=label).pack(anchor="w", padx=5, pady=(5,0))
        widget.pack(fill="x", padx=5, pady=(0,5))

    # --- ESTA ES LA FUNCIÓN QUE FALTABA ---
    def _toggle_traslado_a(self, *args):
        if self.traslado_var.get() == "Sí":
            self.traslado_a_label.pack(anchor="w", padx=5, pady=(5,0))
            self.traslado_a_entry.pack(fill="x", padx=5, pady=(0,5))
        else:
            self.traslado_a_label.pack_forget()
            self.traslado_a_entry.pack_forget()

    def llenar_formulario(self):
        data = self.grua_data
        self.tipo_cb.set(data.get('tipo', ''))
        self.color_entry.insert(0, data.get('color', ''))
        self.marca_entry.set(data.get('marca', ''))
        self.placa_entry.insert(0, data.get('placa', ''))
        self.empresa_entry.insert(0, data.get('empresa', ''))
        self.piloto_entry.insert(0, data.get('piloto', ''))
        self.traslado_var.set(data.get('traslado', 'No'))
        self.traslado_a_entry.insert(0, data.get('traslado_a', ''))
        
        idx_vehiculo = data.get('asignado_a_idx', -1)
        for texto, idx in self.opciones_vehiculos_map.items():
            if idx == idx_vehiculo:
                self.asignar_var.set(texto)
                break

    def guardar(self):
        asignado_texto = self.asignar_var.get()
        asignado_idx = self.opciones_vehiculos_map.get(asignado_texto, -1)

        grua = {
            'tipo': self.tipo_cb.get(),
            'color': self.color_entry.get(),
            'marca': self.marca_entry.get(),
            'placa': self.placa_entry.get(),
            'empresa': self.empresa_entry.get(), 
            'piloto': self.piloto_entry.get(),
            'asignado_a_idx': asignado_idx, 
            'traslado': self.traslado_var.get(),
            'traslado_a': self.traslado_a_entry.get() if self.traslado_var.get() == "Sí" else ""
        }
        
        if self.index is not None:
            self.app.gruas_registradas[self.index] = grua
        else:
            self.app.gruas_registradas.append(grua)
        
        self.callback()
        self.destroy()
        
# --- INICIO CAMBIO: Nueva clase para Popup de Ajustador ---
class AjustadorPopup(tk.Toplevel):
    # Dentro de la clase AjustadorPopup...

    # Dentro de la clase AjustadorPopup...

# Dentro de la clase AjustadorPopup...

    # --- REEMPLAZA TU __init__ COMPLETO CON ESTE ---
    def __init__(self, app_instance, callback, ajustador_data=None, index=None):
        super().__init__(app_instance)
        self.app = app_instance
        self.callback = callback
        self.ajustador_data = ajustador_data
        self.index = index
        
        self.title("Datos del Ajustador" if not ajustador_data else "Editar Datos del Ajustador")
        self.geometry("400x500")
        self.resizable(False, False)

        main_frame = ttk.Frame(self)
        main_frame.pack(fill="both", expand=True, padx=10, pady=10)

        self.nombre_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "Nombre del ajustador", self.nombre_entry)
        
        self.empresa_entry = ttk.Entry(main_frame)
        self._agregar_widget(main_frame, "Empresa / Aseguradora", self.empresa_entry)
        
        vehiculo_frame = ttk.LabelFrame(main_frame, text="Vehículo del ajustador")
        vehiculo_frame.pack(fill="x", padx=5, pady=10)

        self.tipo_vehiculo_entry = SearchableEntry(vehiculo_frame, values=VEHICULO_TIPOS)
        self._agregar_widget(vehiculo_frame, "Tipo", self.tipo_vehiculo_entry)

        self.color_entry = ttk.Entry(vehiculo_frame)
        self._agregar_widget(vehiculo_frame, "Color", self.color_entry)
        
        self.marca_entry = SearchableEntry(vehiculo_frame, values=VEHICULO_MARCAS)
        self._agregar_widget(vehiculo_frame, "Marca", self.marca_entry)

        self.placa_entry = ttk.Entry(vehiculo_frame)
        self._agregar_widget(vehiculo_frame, "Placa", self.placa_entry)

        opciones_vehiculos = {f"Vehículo {i+1} ({v['placa']})": i for i, v in enumerate(self.app.vehiculos_registrados)}
        opciones_vehiculos["No asignar"] = -1
        self.asignar_var = tk.StringVar(value="No asignar")
        self.asignar_cb = ttk.Combobox(main_frame, textvariable=self.asignar_var, values=list(opciones_vehiculos.keys()), state="readonly")
        self._agregar_widget(main_frame, "Asignar a vehículo", self.asignar_cb)
        self.opciones_vehiculos_map = opciones_vehiculos

        if self.ajustador_data:
            self.llenar_formulario()

        ttk.Button(main_frame, text="Guardar", command=self.guardar).pack(pady=20)
        self.transient(app_instance); self.grab_set(); self.focus_set()
    def _agregar_widget(self, container, label, widget):
        ttk.Label(container, text=label).pack(anchor="w", padx=5, pady=(5,0))
        widget.pack(fill="x", padx=5, pady=(0,5))
    def llenar_formulario(self):
        data = self.ajustador_data
        self.nombre_entry.insert(0, data.get('nombre', ''))
        self.empresa_entry.insert(0, data.get('empresa', ''))
        self.tipo_vehiculo_entry.set(data.get('tipo_vehiculo', '')) # Usar .set()
        self.color_entry.insert(0, data.get('color', ''))
        self.marca_entry.set(data.get('marca', ''))
        self.placa_entry.insert(0, data.get('placa', ''))
        
        idx_vehiculo = data.get('asignado_a_idx', -1)
        for texto, idx in self.opciones_vehiculos_map.items():
            if idx == idx_vehiculo:
                self.asignar_var.set(texto)
                break

    def guardar(self):
        asignado_texto = self.asignar_var.get()
        asignado_idx = self.opciones_vehiculos_map.get(asignado_texto, -1)

        ajustador = {
            'nombre': self.nombre_entry.get(), 
            'empresa': self.empresa_entry.get(),
            'tipo_vehiculo': self.tipo_vehiculo_entry.get(), # Usar .get()
            'color': self.color_entry.get(),
            'marca': self.marca_entry.get(),
            'placa': self.placa_entry.get(),
            'asignado_a_idx': asignado_idx
        }
        
        if self.index is not None:
            self.app.ajustadores_registrados[self.index] = ajustador
        else:
            self.app.ajustadores_registrados.append(ajustador)
        
        self.callback()
        self.destroy()

# === Ventana de resultado ===
class ResultadoWindow(tk.Toplevel):
    def __init__(self, master, titulo, mensaje):
        super().__init__(master)
        self.title(titulo)
        self.geometry("600x500")
        
        self.transient(master)
        self.grab_set()

        self.update_idletasks()
        x = master.winfo_x() + (master.winfo_width() // 2) - (self.winfo_width() // 2)
        y = master.winfo_y() + (master.winfo_height() // 2) - (self.winfo_height() // 2)
        self.geometry(f"+{x}+{y}")
        
        main_frame = ttk.Frame(self)
        main_frame.pack(fill="both", expand=True, padx=10, pady=10)
        
        ttk.Label(main_frame, text=titulo, font=("Segoe UI", 12, "bold")).pack(pady=(0, 10))
        
        text_widget = scrolledtext.ScrolledText(main_frame, wrap=tk.WORD, width=70, height=25)
        text_widget.pack(fill="both", expand=True)
        text_widget.insert("1.0", mensaje)
        text_widget.config(state="disabled")
        
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill="x", pady=(10, 0))
        
        def copiar():
            self.clipboard_clear()
            self.clipboard_append(mensaje)
            messagebox.showinfo("Copiado", "Mensaje copiado al portapapeles", parent=self)
        
        ttk.Button(button_frame, text="Copiar", command=copiar).pack(side="left")
        ttk.Button(button_frame, text="Cerrar", command=self.destroy).pack(side="right")


if __name__ == "__main__":
    app = ProvialApp()
    app.mainloop()