import { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import { Icon, LatLngExpression } from 'leaflet';
import { useQuery } from '@tanstack/react-query';
import { incidentesAPI, situacionesAPI } from '../services/api';
import type { Incidente } from '../types';
import { useAuthStore } from '../store/authStore';
import { useNavigate } from 'react-router-dom';
import ResumenUnidadesTable from '../components/ResumenUnidadesTable';

// Fix para iconos de Leaflet en Vite
const createCustomIcon = (color: string) => {
  const svgIcon = `
    <svg xmlns="http://www.w3.org/2000/svg" width="25" height="41" viewBox="0 0 25 41">
      <path fill="${color}" d="M12.5 0C5.6 0 0 5.6 0 12.5c0 8.3 12.5 28.5 12.5 28.5S25 20.8 25 12.5C25 5.6 19.4 0 12.5 0zm0 18c-3 0-5.5-2.5-5.5-5.5S9.5 7 12.5 7s5.5 2.5 5.5 5.5S15.5 18 12.5 18z"/>
    </svg>
  `;

  return new Icon({
    iconUrl: `data:image/svg+xml;base64,${btoa(svgIcon)}`,
    iconSize: [25, 41],
    iconAnchor: [12, 41],
    popupAnchor: [1, -34],
  });
};

// Iconos para Incidentes
const iconReportado = createCustomIcon('#EF4444'); // Rojo
const iconEnAtencion = createCustomIcon('#F59E0B'); // Amarillo
const iconRegulacion = createCustomIcon('#3B82F6'); // Azul
const iconCerrado = createCustomIcon('#10B981'); // Verde

// Iconos para Situaciones (unidades)
const iconUnidadActiva = createCustomIcon('#8B5CF6'); // Púrpura
const iconUnidadParada = createCustomIcon('#14B8A6'); // Teal
const iconUnidadAtendiendo = createCustomIcon('#F97316'); // Naranja

// Componente para actualizar el centro del mapa
function MapController({ center }: { center: LatLngExpression }) {
  const map = useMap();
  useEffect(() => {
    map.setView(center, map.getZoom());
  }, [center, map]);
  return null;
}

export default function DashboardPage() {
  const { user, logout } = useAuthStore();
  const navigate = useNavigate();
  const [selectedIncidente, setSelectedIncidente] = useState<Incidente | null>(null);
  const [selectedSituacion, setSelectedSituacion] = useState<any | null>(null);
  const [vistaActual, setVistaActual] = useState<'todo' | 'incidentes' | 'unidades'>('todo');
  const [modoVista, setModoVista] = useState<'mapa' | 'tabla'>('mapa');

  // Centro de Guatemala (CA-9 aprox)
  const defaultCenter: LatLngExpression = [14.6407, -90.5133];

  // Obtener incidentes activos
  const { data: incidentes = [], isLoading: loadingIncidentes, refetch: refetchIncidentes } = useQuery({
    queryKey: ['incidentes-activos'],
    queryFn: incidentesAPI.getActivos,
    refetchInterval: 30000, // Refrescar cada 30 segundos
  });

  // Obtener situaciones activas
  const { data: situaciones = [], isLoading: loadingSituaciones, refetch: refetchSituaciones } = useQuery({
    queryKey: ['situaciones-activas'],
    queryFn: situacionesAPI.getActivas,
    refetchInterval: 30000, // Refrescar cada 30 segundos
  });

  // Obtener resumen de unidades
  const { data: resumenUnidades = [], isLoading: loadingResumen, refetch: refetchResumen } = useQuery({
    queryKey: ['resumen-unidades'],
    queryFn: situacionesAPI.getResumenUnidades,
    refetchInterval: 30000, // Refrescar cada 30 segundos
  });

  const isLoading = loadingIncidentes || loadingSituaciones || loadingResumen;

  const refetch = () => {
    refetchIncidentes();
    refetchSituaciones();
    refetchResumen();
  };

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const getIncidenteIcon = (estado: string) => {
    switch (estado) {
      case 'REPORTADO':
        return iconReportado;
      case 'EN_ATENCION':
        return iconEnAtencion;
      case 'REGULACION':
        return iconRegulacion;
      case 'CERRADO':
        return iconCerrado;
      default:
        return iconReportado;
    }
  };

  const getSituacionIcon = (tipo: string) => {
    if (tipo?.toLowerCase().includes('parada')) {
      return iconUnidadParada;
    }
    if (tipo?.toLowerCase().includes('atendiendo') || tipo?.toLowerCase().includes('hecho')) {
      return iconUnidadAtendiendo;
    }
    return iconUnidadActiva;
  };

  const getEstadoBadgeColor = (estado: string) => {
    switch (estado) {
      case 'REPORTADO':
        return 'bg-red-100 text-red-800';
      case 'EN_ATENCION':
        return 'bg-yellow-100 text-yellow-800';
      case 'REGULACION':
        return 'bg-blue-100 text-blue-800';
      case 'CERRADO':
        return 'bg-green-100 text-green-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Sidebar */}
      <div className="w-96 bg-white shadow-lg flex flex-col">
        {/* Header */}
        <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-blue-600 to-blue-700">
          <h1 className="text-2xl font-bold text-white mb-1">PROVIAL COP</h1>
          <p className="text-blue-100 text-sm">Centro de Operaciones</p>
          <div className="mt-4 flex items-center justify-between">
            <div className="text-white">
              <p className="text-sm opacity-90">Usuario:</p>
              <p className="font-semibold">{user?.nombre} {user?.apellido}</p>
              <p className="text-xs opacity-75">{user?.rol}</p>
            </div>
            <button
              onClick={handleLogout}
              className="px-4 py-2 bg-white/20 hover:bg-white/30 text-white rounded-lg text-sm transition"
            >
              Salir
            </button>
          </div>
        </div>

        {/* Stats */}
        <div className="p-4 border-b border-gray-200 bg-gray-50">
          <div className="grid grid-cols-3 gap-2">
            <div className="bg-white p-2 rounded-lg shadow-sm">
              <p className="text-xs text-gray-500 mb-1">Incidentes</p>
              <p className="text-xl font-bold text-red-600">
                {incidentes.length}
              </p>
            </div>
            <div className="bg-white p-2 rounded-lg shadow-sm">
              <p className="text-xs text-gray-500 mb-1">Unidades</p>
              <p className="text-xl font-bold text-purple-600">
                {situaciones.length}
              </p>
            </div>
            <div className="bg-white p-2 rounded-lg shadow-sm">
              <p className="text-xs text-gray-500 mb-1">Con heridos</p>
              <p className="text-xl font-bold text-orange-600">
                {incidentes.filter((i) => i.hay_heridos).length}
              </p>
            </div>
          </div>
        </div>

        {/* Filtros de vista */}
        <div className="p-3 border-b border-gray-200 bg-white">
          <div className="flex gap-2 mb-2">
            <button
              onClick={() => setVistaActual('todo')}
              className={`flex-1 px-3 py-2 rounded-lg text-xs font-medium transition ${
                vistaActual === 'todo'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Todo
            </button>
            <button
              onClick={() => setVistaActual('incidentes')}
              className={`flex-1 px-3 py-2 rounded-lg text-xs font-medium transition ${
                vistaActual === 'incidentes'
                  ? 'bg-red-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Hechos
            </button>
            <button
              onClick={() => setVistaActual('unidades')}
              className={`flex-1 px-3 py-2 rounded-lg text-xs font-medium transition ${
                vistaActual === 'unidades'
                  ? 'bg-purple-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Unidades
            </button>
          </div>

          {/* Toggle Mapa/Tabla */}
          <div className="flex gap-2">
            <button
              onClick={() => setModoVista('mapa')}
              className={`flex-1 px-3 py-1.5 rounded-lg text-xs font-medium transition ${
                modoVista === 'mapa'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              🗺️ Mapa
            </button>
            <button
              onClick={() => setModoVista('tabla')}
              className={`flex-1 px-3 py-1.5 rounded-lg text-xs font-medium transition ${
                modoVista === 'tabla'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              📊 Tabla
            </button>
          </div>
        </div>

        {/* Lista de Incidentes y Situaciones */}
        <div className="flex-1 overflow-y-auto p-4 space-y-3">
          <div className="flex items-center justify-between mb-2">
            <h2 className="text-lg font-semibold text-gray-800">
              {vistaActual === 'incidentes' && 'Hechos de Tránsito'}
              {vistaActual === 'unidades' && 'Unidades en Ruta'}
              {vistaActual === 'todo' && 'Situación General'}
            </h2>
            <button
              onClick={() => refetch()}
              className="p-2 hover:bg-gray-100 rounded-lg transition"
              title="Actualizar"
            >
              <svg
                className="w-5 h-5 text-gray-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                />
              </svg>
            </button>
          </div>

          {isLoading && (
            <div className="text-center py-8 text-gray-500">
              Cargando datos...
            </div>
          )}

          {!isLoading && incidentes.length === 0 && situaciones.length === 0 && (
            <div className="text-center py-8 text-gray-500">
              No hay elementos activos
            </div>
          )}

          {/* Mostrar Incidentes */}
          {(vistaActual === 'todo' || vistaActual === 'incidentes') && incidentes.map((incidente) => (
            <div
              key={incidente.id}
              onClick={() => setSelectedIncidente(incidente)}
              className={`bg-white p-4 rounded-lg shadow-sm hover:shadow-md transition cursor-pointer border-l-4 ${
                selectedIncidente?.id === incidente.id
                  ? 'border-blue-500 bg-blue-50'
                  : 'border-gray-200'
              }`}
            >
              <div className="flex items-start justify-between mb-2">
                <span className="font-semibold text-gray-800">
                  {incidente.numero_reporte || `#${incidente.id}`}
                </span>
                <span
                  className={`px-2 py-1 rounded-full text-xs font-medium ${getEstadoBadgeColor(
                    incidente.estado
                  )}`}
                >
                  {incidente.estado}
                </span>
              </div>

              <p className="text-sm font-medium text-gray-700 mb-1">
                {incidente.tipo_hecho}
              </p>

              <div className="text-xs text-gray-600 space-y-1">
                <p>
                  📍 {incidente.ruta_codigo} Km {incidente.km}
                  {incidente.sentido && ` (${incidente.sentido})`}
                </p>
                {incidente.unidad_codigo && (
                  <p>🚓 {incidente.unidad_codigo}</p>
                )}
                {(incidente.hay_heridos || incidente.hay_fallecidos) && (
                  <p className="text-red-600 font-medium">
                    ⚠️ {incidente.cantidad_heridos} heridos
                    {incidente.hay_fallecidos &&
                      `, ${incidente.cantidad_fallecidos} fallecidos`}
                  </p>
                )}
              </div>
            </div>
          ))}

          {/* Mostrar Situaciones */}
          {(vistaActual === 'todo' || vistaActual === 'unidades') && situaciones.map((situacion: any) => (
            <div
              key={`situacion-${situacion.id}`}
              onClick={() => {
                setSelectedSituacion(situacion);
                setSelectedIncidente(null);
              }}
              className={`bg-white p-4 rounded-lg shadow-sm hover:shadow-md transition cursor-pointer border-l-4 ${
                selectedSituacion?.id === situacion.id
                  ? 'border-purple-500 bg-purple-50'
                  : 'border-purple-200'
              }`}
            >
              <div className="flex items-start justify-between mb-2">
                <span className="font-semibold text-gray-800">
                  🚓 {situacion.unidad_codigo || `Unidad #${situacion.unidad_id}`}
                </span>
                <span className="px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                  {situacion.tipo_situacion?.replace(/_/g, ' ')}
                </span>
              </div>

              <p className="text-sm font-medium text-purple-700 mb-1">
                {situacion.descripcion || 'Sin descripción'}
              </p>

              <div className="text-xs text-gray-600 space-y-1">
                {situacion.ruta_codigo && (
                  <p>
                    📍 {situacion.ruta_codigo} Km {situacion.km}
                    {situacion.sentido && ` (${situacion.sentido})`}
                  </p>
                )}
                {situacion.turno_fecha && (
                  <p>📅 {new Date(situacion.turno_fecha).toLocaleDateString('es-GT')}</p>
                )}
                {situacion.observaciones && (
                  <p className="text-gray-500 italic text-xs mt-1">
                    {situacion.observaciones}
                  </p>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Área principal: Mapa o Tabla */}
      <div className="flex-1 relative">
        {modoVista === 'mapa' ? (
          <MapContainer
            center={defaultCenter}
            zoom={11}
            style={{ height: '100%', width: '100%' }}
          >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />

          <MapController center={defaultCenter} />

          {/* Marcadores de Incidentes */}
          {(vistaActual === 'todo' || vistaActual === 'incidentes') && incidentes.map((incidente) => {
            if (!incidente.latitud || !incidente.longitud) return null;

            return (
              <Marker
                key={`incidente-${incidente.id}`}
                position={[incidente.latitud, incidente.longitud]}
                icon={getIncidenteIcon(incidente.estado)}
                eventHandlers={{
                  click: () => setSelectedIncidente(incidente),
                }}
              >
                <Popup>
                  <div className="p-2 min-w-[200px]">
                    <h3 className="font-bold text-lg mb-2">
                      {incidente.numero_reporte || `#${incidente.id}`}
                    </h3>
                    <p className="font-semibold text-gray-700 mb-2">
                      {incidente.tipo_hecho}
                    </p>
                    <div className="text-sm space-y-1">
                      <p>
                        📍 {incidente.ruta_codigo} Km {incidente.km}
                      </p>
                      <p>
                        Estado:{' '}
                        <span
                          className={`px-2 py-0.5 rounded-full text-xs font-medium ${getEstadoBadgeColor(
                            incidente.estado
                          )}`}
                        >
                          {incidente.estado}
                        </span>
                      </p>
                      {incidente.unidad_codigo && (
                        <p>🚓 {incidente.unidad_codigo}</p>
                      )}
                      {incidente.observaciones_iniciales && (
                        <p className="mt-2 text-gray-600">
                          {incidente.observaciones_iniciales}
                        </p>
                      )}
                    </div>
                  </div>
                </Popup>
              </Marker>
            );
          })}

          {/* Marcadores de Situaciones */}
          {(vistaActual === 'todo' || vistaActual === 'unidades') && situaciones.map((situacion: any) => {
            if (!situacion.latitud || !situacion.longitud) return null;

            return (
              <Marker
                key={`situacion-${situacion.id}`}
                position={[situacion.latitud, situacion.longitud]}
                icon={getSituacionIcon(situacion.tipo_situacion)}
                eventHandlers={{
                  click: () => {
                    setSelectedSituacion(situacion);
                    setSelectedIncidente(null);
                  },
                }}
              >
                <Popup>
                  <div className="p-2 min-w-[200px]">
                    <h3 className="font-bold text-lg mb-2 text-purple-700">
                      🚓 {situacion.unidad_codigo || `Unidad #${situacion.unidad_id}`}
                    </h3>
                    <p className="font-semibold text-gray-700 mb-2">
                      {situacion.tipo_situacion?.replace(/_/g, ' ')}
                    </p>
                    <div className="text-sm space-y-1">
                      {situacion.ruta_codigo && (
                        <p>
                          📍 {situacion.ruta_codigo} Km {situacion.km}
                          {situacion.sentido && ` (${situacion.sentido})`}
                        </p>
                      )}
                      <p>
                        Estado:{' '}
                        <span className="px-2 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                          {situacion.estado || 'ACTIVA'}
                        </span>
                      </p>
                      {situacion.descripcion && (
                        <p className="mt-2 text-gray-700">
                          {situacion.descripcion}
                        </p>
                      )}
                      {situacion.observaciones && (
                        <p className="mt-1 text-gray-600 text-xs italic">
                          {situacion.observaciones}
                        </p>
                      )}
                    </div>
                  </div>
                </Popup>
              </Marker>
            );
          })}
          </MapContainer>
        ) : (
          // Vista de Tabla
          <div className="h-full overflow-auto p-4 bg-gray-50">
            <ResumenUnidadesTable
              resumen={resumenUnidades}
              onSelectUnidad={(unidadId) => {
                // Encontrar la unidad y centrar el mapa en ella
                const unidad = resumenUnidades.find((u: any) => u.unidad_id === unidadId);
                if (unidad) {
                  setModoVista('mapa');
                  // Aquí podrías agregar lógica para centrar el mapa
                }
              }}
            />
          </div>
        )}

        {/* Panel de detalles flotante */}
        {selectedIncidente && (
          <div className="absolute top-4 right-4 w-96 bg-white rounded-lg shadow-2xl max-h-[calc(100vh-2rem)] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h2 className="text-2xl font-bold text-gray-800">
                    {selectedIncidente.numero_reporte || `#${selectedIncidente.id}`}
                  </h2>
                  <p className="text-gray-600">{selectedIncidente.tipo_hecho}</p>
                </div>
                <button
                  onClick={() => setSelectedIncidente(null)}
                  className="p-2 hover:bg-gray-100 rounded-lg transition"
                >
                  <svg
                    className="w-6 h-6 text-gray-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <span
                    className={`inline-block px-3 py-1 rounded-full text-sm font-medium ${getEstadoBadgeColor(
                      selectedIncidente.estado
                    )}`}
                  >
                    {selectedIncidente.estado}
                  </span>
                </div>

                <div>
                  <h3 className="text-sm font-semibold text-gray-500 mb-2">
                    Ubicación
                  </h3>
                  <p className="text-gray-800">
                    {selectedIncidente.ruta_codigo} Km {selectedIncidente.km}
                    {selectedIncidente.sentido && ` (${selectedIncidente.sentido})`}
                  </p>
                  {selectedIncidente.referencia_ubicacion && (
                    <p className="text-sm text-gray-600 mt-1">
                      {selectedIncidente.referencia_ubicacion}
                    </p>
                  )}
                </div>

                {selectedIncidente.unidad_codigo && (
                  <div>
                    <h3 className="text-sm font-semibold text-gray-500 mb-2">
                      Unidad Asignada
                    </h3>
                    <p className="text-gray-800">
                      🚓 {selectedIncidente.unidad_codigo}
                    </p>
                    {selectedIncidente.brigada_nombre && (
                      <p className="text-sm text-gray-600">
                        {selectedIncidente.brigada_nombre}
                      </p>
                    )}
                  </div>
                )}

                {(selectedIncidente.hay_heridos ||
                  selectedIncidente.hay_fallecidos) && (
                  <div className="bg-red-50 p-3 rounded-lg">
                    <h3 className="text-sm font-semibold text-red-800 mb-2">
                      ⚠️ Víctimas
                    </h3>
                    <div className="space-y-1 text-sm">
                      {selectedIncidente.hay_heridos && (
                        <p className="text-red-700">
                          🤕 {selectedIncidente.cantidad_heridos} heridos
                        </p>
                      )}
                      {selectedIncidente.hay_fallecidos && (
                        <p className="text-red-700">
                          💀 {selectedIncidente.cantidad_fallecidos} fallecidos
                        </p>
                      )}
                    </div>
                  </div>
                )}

                {selectedIncidente.observaciones_iniciales && (
                  <div>
                    <h3 className="text-sm font-semibold text-gray-500 mb-2">
                      Observaciones
                    </h3>
                    <p className="text-gray-700 text-sm">
                      {selectedIncidente.observaciones_iniciales}
                    </p>
                  </div>
                )}

                <div>
                  <h3 className="text-sm font-semibold text-gray-500 mb-2">
                    Hora de Reporte
                  </h3>
                  <p className="text-gray-700 text-sm">
                    {new Date(selectedIncidente.fecha_hora_aviso).toLocaleString(
                      'es-GT'
                    )}
                  </p>
                </div>

                <button
                  onClick={() => navigate(`/incidentes/${selectedIncidente.id}`)}
                  className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg transition"
                >
                  Ver Detalles Completos
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Panel de detalles de Situación */}
        {selectedSituacion && !selectedIncidente && (
          <div className="absolute top-4 right-4 w-96 bg-white rounded-lg shadow-2xl max-h-[calc(100vh-2rem)] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h2 className="text-2xl font-bold text-purple-700">
                    🚓 {selectedSituacion.unidad_codigo || `Unidad #${selectedSituacion.unidad_id}`}
                  </h2>
                  <p className="text-gray-600">{selectedSituacion.tipo_situacion?.replace(/_/g, ' ')}</p>
                </div>
                <button
                  onClick={() => setSelectedSituacion(null)}
                  className="p-2 hover:bg-gray-100 rounded-lg transition"
                >
                  <svg
                    className="w-6 h-6 text-gray-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <span className="inline-block px-3 py-1 rounded-full text-sm font-medium bg-purple-100 text-purple-800">
                    {selectedSituacion.estado || 'ACTIVA'}
                  </span>
                </div>

                {selectedSituacion.ruta_codigo && (
                  <div>
                    <h3 className="text-sm font-semibold text-gray-500 mb-2">
                      Ubicación
                    </h3>
                    <p className="text-gray-800">
                      {selectedSituacion.ruta_codigo} Km {selectedSituacion.km}
                      {selectedSituacion.sentido && ` (${selectedSituacion.sentido})`}
                    </p>
                  </div>
                )}

                {selectedSituacion.descripcion && (
                  <div>
                    <h3 className="text-sm font-semibold text-gray-500 mb-2">
                      Descripción
                    </h3>
                    <p className="text-gray-700 text-sm">
                      {selectedSituacion.descripcion}
                    </p>
                  </div>
                )}

                {selectedSituacion.observaciones && (
                  <div>
                    <h3 className="text-sm font-semibold text-gray-500 mb-2">
                      Observaciones
                    </h3>
                    <p className="text-gray-700 text-sm">
                      {selectedSituacion.observaciones}
                    </p>
                  </div>
                )}

                {selectedSituacion.combustible !== null && selectedSituacion.combustible !== undefined && (
                  <div>
                    <h3 className="text-sm font-semibold text-gray-500 mb-2">
                      Nivel de Combustible
                    </h3>
                    <p className="text-gray-800">{selectedSituacion.combustible}%</p>
                  </div>
                )}

                {selectedSituacion.kilometraje_unidad && (
                  <div>
                    <h3 className="text-sm font-semibold text-gray-500 mb-2">
                      Kilometraje de Unidad
                    </h3>
                    <p className="text-gray-800">{selectedSituacion.kilometraje_unidad.toLocaleString()} km</p>
                  </div>
                )}

                <div>
                  <h3 className="text-sm font-semibold text-gray-500 mb-2">
                    Hora de Registro
                  </h3>
                  <p className="text-gray-700 text-sm">
                    {new Date(selectedSituacion.created_at).toLocaleString('es-GT')}
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
