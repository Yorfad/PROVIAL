import { useState } from 'react';

interface ResumenUnidad {
  unidad_id: number;
  unidad_codigo: string;
  tipo_unidad: string;
  placa: string;
  sede_nombre: string;
  situacion_id: number | null;
  tipo_situacion: string | null;
  situacion_estado: string | null;
  km: number | null;
  sentido: string | null;
  ruta_codigo: string | null;
  ruta_activa_codigo: string | null;
  combustible: number | null;
  combustible_fraccion: string | null;
  situacion_descripcion: string | null;
  situacion_fecha: string | null;
  tripulacion: Array<{
    nombre_completo: string;
    rol_tripulacion: string;
  }>;
}

interface Props {
  resumen: ResumenUnidad[];
  onSelectUnidad?: (unidadId: number) => void;
}

export default function ResumenUnidadesTable({ resumen, onSelectUnidad }: Props) {
  const [search, setSearch] = useState('');

  const formatHora = (fecha: string | null) => {
    if (!fecha) return '-';
    const date = new Date(fecha);
    return date.toLocaleTimeString('es-GT', { hour: '2-digit', minute: '2-digit' });
  };

  const getEstadoBadgeClass = (estado: string | null) => {
    switch (estado) {
      case 'ACTIVA':
        return 'bg-green-100 text-green-800';
      case 'CERRADA':
        return 'bg-gray-100 text-gray-800';
      default:
        return 'bg-blue-100 text-blue-800';
    }
  };

  const getTipoSituacionBadgeClass = (tipo: string | null) => {
    if (!tipo) return 'bg-gray-100 text-gray-600';

    const tipoLower = tipo.toLowerCase();
    if (tipoLower.includes('incidente')) return 'bg-red-100 text-red-800';
    if (tipoLower.includes('patrullaje')) return 'bg-blue-100 text-blue-800';
    if (tipoLower.includes('parada')) return 'bg-yellow-100 text-yellow-800';
    if (tipoLower.includes('comida')) return 'bg-orange-100 text-orange-800';
    return 'bg-purple-100 text-purple-800';
  };

  const filteredResumen = resumen.filter((u) => {
    const searchLower = search.toLowerCase();
    return (
      u.unidad_codigo.toLowerCase().includes(searchLower) ||
      u.tipo_unidad.toLowerCase().includes(searchLower) ||
      u.sede_nombre?.toLowerCase().includes(searchLower) ||
      u.placa?.toLowerCase().includes(searchLower)
    );
  });

  return (
    <div className="bg-white rounded-lg shadow">
      {/* Header con búsqueda */}
      <div className="p-4 border-b border-gray-200">
        <div className="flex items-center justify-between mb-2">
          <h2 className="text-xl font-semibold text-gray-800">
            Resumen de Unidades
          </h2>
          <span className="text-sm text-gray-500">
            {filteredResumen.length} de {resumen.length} unidades
          </span>
        </div>
        <input
          type="text"
          placeholder="Buscar unidad, tipo, sede..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        />
      </div>

      {/* Tabla */}
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50 border-b border-gray-200">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Unidad
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Situación Actual
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Ubicación
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Ruta Activa
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Combustible
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Tripulación
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Última Hora
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {filteredResumen.map((unidad) => (
              <tr
                key={unidad.unidad_id}
                onClick={() => onSelectUnidad?.(unidad.unidad_id)}
                className="hover:bg-gray-50 cursor-pointer transition"
              >
                {/* Unidad */}
                <td className="px-4 py-4 whitespace-nowrap">
                  <div>
                    <div className="text-sm font-medium text-gray-900">
                      {unidad.unidad_codigo}
                    </div>
                    <div className="text-xs text-gray-500">
                      {unidad.tipo_unidad}
                    </div>
                    {unidad.sede_nombre && (
                      <div className="text-xs text-gray-400">
                        {unidad.sede_nombre}
                      </div>
                    )}
                  </div>
                </td>

                {/* Situación Actual */}
                <td className="px-4 py-4">
                  {unidad.tipo_situacion ? (
                    <div className="space-y-1">
                      <span
                        className={`inline-block px-2 py-1 text-xs font-medium rounded-full ${getTipoSituacionBadgeClass(
                          unidad.tipo_situacion
                        )}`}
                      >
                        {unidad.tipo_situacion.replace(/_/g, ' ')}
                      </span>
                      <div>
                        <span
                          className={`inline-block px-2 py-0.5 text-xs rounded-full ${getEstadoBadgeClass(
                            unidad.situacion_estado
                          )}`}
                        >
                          {unidad.situacion_estado}
                        </span>
                      </div>
                    </div>
                  ) : (
                    <span className="text-sm text-gray-400">Sin situación</span>
                  )}
                </td>

                {/* Ubicación */}
                <td className="px-4 py-4 whitespace-nowrap">
                  {unidad.ruta_codigo ? (
                    <div className="text-sm">
                      <div className="font-medium text-gray-900">
                        {unidad.ruta_codigo} Km {unidad.km || '-'}
                      </div>
                      {unidad.sentido && (
                        <div className="text-xs text-gray-500">
                          {unidad.sentido}
                        </div>
                      )}
                    </div>
                  ) : (
                    <span className="text-sm text-gray-400">-</span>
                  )}
                </td>

                {/* Ruta Activa */}
                <td className="px-4 py-4 whitespace-nowrap">
                  {unidad.ruta_activa_codigo ? (
                    <div className="text-sm">
                      <div className="font-medium text-gray-900">
                        {unidad.ruta_activa_codigo}
                      </div>
                    </div>
                  ) : (
                    <span className="text-sm text-gray-400">Sin ruta</span>
                  )}
                </td>

                {/* Combustible */}
                <td className="px-4 py-4 whitespace-nowrap">
                  {unidad.combustible_fraccion || unidad.combustible ? (
                    <div className="text-sm">
                      <div className="font-medium text-gray-900">
                        {unidad.combustible_fraccion || `${Math.round((unidad.combustible || 0) * 100)}%`}
                      </div>
                    </div>
                  ) : (
                    <span className="text-sm text-gray-400">-</span>
                  )}
                </td>

                {/* Tripulación */}
                <td className="px-4 py-4">
                  {unidad.tripulacion && unidad.tripulacion.length > 0 ? (
                    <div className="text-xs space-y-0.5">
                      {unidad.tripulacion.map((t, idx) => (
                        <div key={idx} className="text-gray-700">
                          <span className="font-medium">
                            {t.rol_tripulacion}:
                          </span>{' '}
                          {t.nombre_completo}
                        </div>
                      ))}
                    </div>
                  ) : (
                    <span className="text-sm text-gray-400">Sin tripulación</span>
                  )}
                </td>

                {/* Última Hora */}
                <td className="px-4 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-900">
                    {formatHora(unidad.situacion_fecha)}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {filteredResumen.length === 0 && (
        <div className="text-center py-8 text-gray-500">
          No se encontraron unidades
        </div>
      )}
    </div>
  );
}
