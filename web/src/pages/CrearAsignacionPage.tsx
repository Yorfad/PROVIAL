import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { turnosService, geografiaService } from '../services/turnos.service';
import { operacionesService } from '../services/operaciones.service';
import type { TripulacionMiembro, CreateAsignacionDTO } from '../services/turnos.service';
import type { BrigadaDisponible } from '../services/operaciones.service';
import { AlertCircle, CheckCircle, Users, Truck, ArrowLeft, Plus, X } from 'lucide-react';

export default function CrearAsignacionPage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  // Estado del formulario
  const [fecha, setFecha] = useState(new Date().toISOString().split('T')[0]);
  const [unidadId, setUnidadId] = useState<number | null>(null);
  const [rutaId, setRutaId] = useState<number | null>(null);
  const [kmInicio, setKmInicio] = useState('');
  const [kmFinal, setKmFinal] = useState('');
  const [sentido, setSentido] = useState<string>('');
  const [acciones, setAcciones] = useState('');
  const [horaSalida, setHoraSalida] = useState('');
  const [horaEntrada, setHoraEntrada] = useState('');
  const [combustibleInicial, setCombustibleInicial] = useState('');
  const [combustibleAsignado, setCombustibleAsignado] = useState('');
  const [observaciones, setObservaciones] = useState('');

  // Tripulación
  const [tripulacion, setTripulacion] = useState<TripulacionMiembro[]>([]);
  const [showBrigadaModal, setShowBrigadaModal] = useState(false);
  const [rolSeleccionado, setRolSeleccionado] = useState<'PILOTO' | 'COPILOTO' | 'ACOMPAÑANTE' | null>(null);

  // Queries
  const { data: brigadas = [], isLoading: loadingBrigadas } = useQuery({
    queryKey: ['brigadas-disponibles', fecha],
    queryFn: () => operacionesService.getBrigadasDisponibles(fecha),
    enabled: !!fecha,
  });

  const { data: unidades = [], isLoading: loadingUnidades } = useQuery({
    queryKey: ['unidades-disponibles', fecha],
    queryFn: () => operacionesService.getUnidadesDisponibles(fecha),
    enabled: !!fecha,
  });

  const { data: rutas = [] } = useQuery({
    queryKey: ['rutas'],
    queryFn: () => geografiaService.getRutas(),
  });

  // Mutation para crear asignación
  const crearAsignacionMutation = useMutation({
    mutationFn: async (asignacion: CreateAsignacionDTO) => {
      // Primero verificar si existe un turno para esta fecha
      let turno = await turnosService.getTurnoByFecha(fecha);

      // Si no existe, crear el turno
      if (!turno) {
        turno = await turnosService.createTurno({
          fecha,
          observaciones: observaciones || undefined,
        });
      }

      // Crear la asignación
      return turnosService.createAsignacion(turno.id, asignacion);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['turno-hoy'] });
      queryClient.invalidateQueries({ queryKey: ['brigadas-disponibles'] });
      queryClient.invalidateQueries({ queryKey: ['unidades-disponibles'] });
      alert('Asignación creada exitosamente');
      navigate('/operaciones');
    },
    onError: (error: any) => {
      alert(`Error al crear asignación: ${error.response?.data?.error || error.message}`);
    },
  });

  // Handlers
  const agregarTripulante = (brigada: BrigadaDisponible, rol: 'PILOTO' | 'COPILOTO' | 'ACOMPAÑANTE') => {
    if (tripulacion.some(t => t.usuario_id === brigada.id)) {
      alert('Esta brigada ya está asignada a este turno');
      return;
    }

    // Solo permitir un PILOTO y un COPILOTO, pero múltiples ACOMPAÑANTES
    if (rol !== 'ACOMPAÑANTE' && tripulacion.some(t => t.rol_tripulacion === rol)) {
      alert(`Ya hay un ${rol} asignado`);
      return;
    }

    setTripulacion([
      ...tripulacion,
      {
        usuario_id: brigada.id,
        rol_tripulacion: rol,
        telefono_contacto: brigada.telefono || undefined,
        presente: true,
      },
    ]);
    setShowBrigadaModal(false);
    setRolSeleccionado(null);
  };

  const removerTripulante = (usuarioId: number) => {
    setTripulacion(tripulacion.filter(t => t.usuario_id !== usuarioId));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!unidadId) {
      alert('Debe seleccionar una unidad');
      return;
    }

    if (tripulacion.length === 0) {
      alert('Debe asignar al menos un tripulante');
      return;
    }

    const asignacion: CreateAsignacionDTO = {
      unidad_id: unidadId,
      ruta_id: rutaId || undefined,
      km_inicio: kmInicio ? parseFloat(kmInicio) : undefined,
      km_final: kmFinal ? parseFloat(kmFinal) : undefined,
      sentido: (sentido as any) || undefined,
      acciones: acciones || undefined,
      combustible_inicial: combustibleInicial ? parseFloat(combustibleInicial) : undefined,
      combustible_asignado: combustibleAsignado ? parseFloat(combustibleAsignado) : undefined,
      hora_salida: horaSalida || undefined,
      hora_entrada_estimada: horaEntrada || undefined,
      tripulacion,
    };

    crearAsignacionMutation.mutate(asignacion);
  };

  const unidadSeleccionada = unidades.find(u => u.id === unidadId);
  const getBrigadaNombre = (usuarioId: number) => {
    return brigadas.find(b => b.id === usuarioId)?.nombre_completo || 'Desconocido';
  };

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-5xl mx-auto">
        {/* Header */}
        <div className="mb-6 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate('/operaciones')}
              className="p-2 hover:bg-gray-200 rounded-lg transition-colors"
            >
              <ArrowLeft className="h-5 w-5" />
            </button>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Nueva Asignación</h1>
              <p className="text-sm text-gray-600">Asignar unidad y tripulación para un turno</p>
            </div>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Fecha */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold mb-4">Fecha del Turno</h2>
            <input
              type="date"
              value={fecha}
              onChange={(e) => setFecha(e.target.value)}
              className="px-4 py-2 border rounded-lg w-full max-w-xs"
              required
            />
          </div>

          {/* Selección de Unidad */}
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center gap-2 mb-4">
              <Truck className="h-5 w-5 text-blue-600" />
              <h2 className="text-lg font-semibold">Unidad</h2>
            </div>

            {loadingUnidades ? (
              <p className="text-gray-500">Cargando unidades...</p>
            ) : unidades.length === 0 ? (
              <p className="text-gray-500">No hay unidades disponibles para esta fecha</p>
            ) : (
              <div className="space-y-3">
                {unidades.map((unidad) => (
                  <label
                    key={unidad.id}
                    className={`flex items-start gap-3 p-4 border rounded-lg cursor-pointer transition-colors ${
                      unidadId === unidad.id
                        ? 'border-blue-500 bg-blue-50'
                        : 'border-gray-200 hover:border-gray-300'
                    }`}
                  >
                    <input
                      type="radio"
                      name="unidad"
                      value={unidad.id}
                      checked={unidadId === unidad.id}
                      onChange={() => setUnidadId(unidad.id)}
                      className="mt-1"
                    />
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <span className="font-medium">{unidad.codigo}</span>
                        <span className="text-sm text-gray-600">
                          {unidad.marca} {unidad.modelo}
                        </span>
                        {unidad.disponible ? (
                          <CheckCircle className="h-4 w-4 text-green-500" />
                        ) : (
                          <AlertCircle className="h-4 w-4 text-yellow-500" />
                        )}
                      </div>
                      <p className="text-sm text-gray-600 mt-1">{unidad.mensaje}</p>
                      <div className="flex gap-4 mt-2 text-xs text-gray-500">
                        <span>Combustible: {unidad.combustible_actual}L</span>
                        <span>Odómetro: {unidad.odometro_actual} km</span>
                        <span>Turnos último mes: {unidad.turnos_ultimo_mes}</span>
                      </div>
                    </div>
                  </label>
                ))}
              </div>
            )}
          </div>

          {/* Detalles de Ruta */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold mb-4">Detalles de Ruta</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Ruta (opcional)
                </label>
                <select
                  value={rutaId || ''}
                  onChange={(e) => setRutaId(e.target.value ? parseInt(e.target.value) : null)}
                  className="w-full px-4 py-2 border rounded-lg"
                >
                  <option value="">Sin ruta específica</option>
                  {rutas.map((ruta) => (
                    <option key={ruta.id} value={ruta.id}>
                      {ruta.codigo} - {ruta.nombre}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Sentido</label>
                <select
                  value={sentido}
                  onChange={(e) => setSentido(e.target.value)}
                  className="w-full px-4 py-2 border rounded-lg"
                >
                  <option value="">Seleccionar sentido</option>
                  <option value="NORTE">Norte</option>
                  <option value="SUR">Sur</option>
                  <option value="ORIENTE">Oriente</option>
                  <option value="OCCIDENTE">Occidente</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  KM Inicio
                </label>
                <input
                  type="number"
                  step="0.1"
                  value={kmInicio}
                  onChange={(e) => setKmInicio(e.target.value)}
                  placeholder="0.0"
                  className="w-full px-4 py-2 border rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  KM Final
                </label>
                <input
                  type="number"
                  step="0.1"
                  value={kmFinal}
                  onChange={(e) => setKmFinal(e.target.value)}
                  placeholder="0.0"
                  className="w-full px-4 py-2 border rounded-lg"
                />
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Acciones a realizar
                </label>
                <textarea
                  value={acciones}
                  onChange={(e) => setAcciones(e.target.value)}
                  placeholder="Descripción de las acciones..."
                  rows={3}
                  className="w-full px-4 py-2 border rounded-lg"
                />
              </div>
            </div>
          </div>

          {/* Horarios y Combustible */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold mb-4">Horarios y Combustible</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Hora de Salida
                </label>
                <input
                  type="time"
                  value={horaSalida}
                  onChange={(e) => setHoraSalida(e.target.value)}
                  className="w-full px-4 py-2 border rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Hora de Entrada Estimada
                </label>
                <input
                  type="time"
                  value={horaEntrada}
                  onChange={(e) => setHoraEntrada(e.target.value)}
                  className="w-full px-4 py-2 border rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Combustible Inicial (litros)
                </label>
                <input
                  type="number"
                  step="0.1"
                  value={combustibleInicial}
                  onChange={(e) => setCombustibleInicial(e.target.value)}
                  placeholder={unidadSeleccionada ? `${unidadSeleccionada.combustible_actual}` : '0.0'}
                  className="w-full px-4 py-2 border rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Combustible Asignado (litros)
                </label>
                <input
                  type="number"
                  step="0.1"
                  value={combustibleAsignado}
                  onChange={(e) => setCombustibleAsignado(e.target.value)}
                  placeholder="0.0"
                  className="w-full px-4 py-2 border rounded-lg"
                />
              </div>
            </div>
          </div>

          {/* Tripulación */}
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Users className="h-5 w-5 text-blue-600" />
                <h2 className="text-lg font-semibold">Tripulación</h2>
              </div>
              <button
                type="button"
                onClick={() => {
                  setRolSeleccionado('PILOTO');
                  setShowBrigadaModal(true);
                }}
                className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                disabled={tripulacion.length >= 3}
              >
                <Plus className="h-4 w-4" />
                Agregar Tripulante
              </button>
            </div>

            {tripulacion.length === 0 ? (
              <p className="text-gray-500 text-center py-8">
                No hay tripulantes asignados. Agregue al menos un piloto.
              </p>
            ) : (
              <div className="space-y-3">
                {tripulacion.map((miembro) => {
                  const brigada = brigadas.find(b => b.id === miembro.usuario_id);
                  return (
                    <div
                      key={miembro.usuario_id}
                      className="flex items-center justify-between p-4 border rounded-lg"
                    >
                      <div>
                        <div className="flex items-center gap-2">
                          <p className="font-medium">{getBrigadaNombre(miembro.usuario_id)}</p>
                          {brigada && <span className="text-sm text-gray-500">({brigada.chapa})</span>}
                        </div>
                        <p className="text-sm text-gray-600">
                          {miembro.rol_tripulacion}
                          {miembro.telefono_contacto && ` • ${miembro.telefono_contacto}`}
                        </p>
                      </div>
                      <button
                        type="button"
                        onClick={() => removerTripulante(miembro.usuario_id)}
                        className="p-2 text-red-600 hover:bg-red-50 rounded-lg"
                      >
                        <X className="h-5 w-5" />
                      </button>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          {/* Observaciones */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold mb-4">Observaciones</h2>
            <textarea
              value={observaciones}
              onChange={(e) => setObservaciones(e.target.value)}
              placeholder="Observaciones del turno..."
              rows={4}
              className="w-full px-4 py-2 border rounded-lg"
            />
          </div>

          {/* Botones */}
          <div className="flex gap-4 justify-end">
            <button
              type="button"
              onClick={() => navigate('/operaciones')}
              className="px-6 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={crearAsignacionMutation.isPending}
              className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {crearAsignacionMutation.isPending ? 'Creando...' : 'Crear Asignación'}
            </button>
          </div>
        </form>
      </div>

      {/* Modal para seleccionar brigada */}
      {showBrigadaModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[80vh] overflow-hidden flex flex-col">
            <div className="p-6 border-b">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold">
                  Seleccionar {rolSeleccionado}
                </h3>
                <button
                  onClick={() => {
                    setShowBrigadaModal(false);
                    setRolSeleccionado(null);
                  }}
                  className="p-2 hover:bg-gray-100 rounded-lg"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>
              <div className="mt-4 flex gap-2">
                <button
                  onClick={() => setRolSeleccionado('PILOTO')}
                  className={`px-4 py-2 rounded-lg ${
                    rolSeleccionado === 'PILOTO'
                      ? 'bg-blue-600 text-white'
                      : 'bg-gray-200 text-gray-700'
                  }`}
                  disabled={tripulacion.some(t => t.rol_tripulacion === 'PILOTO')}
                >
                  Piloto
                </button>
                <button
                  onClick={() => setRolSeleccionado('COPILOTO')}
                  className={`px-4 py-2 rounded-lg ${
                    rolSeleccionado === 'COPILOTO'
                      ? 'bg-blue-600 text-white'
                      : 'bg-gray-200 text-gray-700'
                  }`}
                  disabled={tripulacion.some(t => t.rol_tripulacion === 'COPILOTO')}
                >
                  Copiloto
                </button>
                <button
                  onClick={() => setRolSeleccionado('ACOMPAÑANTE')}
                  className={`px-4 py-2 rounded-lg ${
                    rolSeleccionado === 'ACOMPAÑANTE'
                      ? 'bg-blue-600 text-white'
                      : 'bg-gray-200 text-gray-700'
                  }`}
                  disabled={tripulacion.some(t => t.rol_tripulacion === 'ACOMPAÑANTE')}
                >
                  Acompañante
                </button>
              </div>
            </div>

            <div className="flex-1 overflow-y-auto p-6">
              {loadingBrigadas ? (
                <p className="text-center text-gray-500">Cargando brigadas...</p>
              ) : brigadas.length === 0 ? (
                <p className="text-center text-gray-500">No hay brigadas disponibles</p>
              ) : (
                <div className="space-y-3">
                  {brigadas.map((brigada) => (
                    <button
                      key={brigada.id}
                      type="button"
                      onClick={() => rolSeleccionado && agregarTripulante(brigada, rolSeleccionado)}
                      disabled={tripulacion.some(t => t.usuario_id === brigada.id)}
                      className={`w-full text-left p-4 border rounded-lg transition-colors ${
                        tripulacion.some(t => t.usuario_id === brigada.id)
                          ? 'opacity-50 cursor-not-allowed bg-gray-100'
                          : brigada.disponible
                          ? 'hover:border-blue-500 hover:bg-blue-50'
                          : 'hover:border-yellow-500 hover:bg-yellow-50'
                      }`}
                    >
                      <div className="flex items-center gap-2">
                        <span className="font-medium">{brigada.nombre_completo}</span>
                        <span className="text-sm text-gray-500">({brigada.chapa})</span>
                        {brigada.disponible ? (
                          <CheckCircle className="h-4 w-4 text-green-500" />
                        ) : (
                          <AlertCircle className="h-4 w-4 text-yellow-500" />
                        )}
                      </div>
                      <p className="text-sm text-gray-600 mt-1">{brigada.mensaje}</p>
                      <div className="flex gap-4 mt-2 text-xs text-gray-500">
                        {brigada.telefono && <span>Tel: {brigada.telefono}</span>}
                        <span>Turnos último mes: {brigada.turnos_ultimo_mes}</span>
                        {brigada.rol_tripulacion_frecuente && (
                          <span>Rol frecuente: {brigada.rol_tripulacion_frecuente}</span>
                        )}
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
