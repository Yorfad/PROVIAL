import { useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useAuthStore } from './store/authStore';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import OperacionesPage from './pages/OperacionesPage';
import CrearAsignacionPage from './pages/CrearAsignacionPage';
import GeneradorTurnosPage from './pages/GeneradorTurnosPage';
import BrigadasPage from './pages/BrigadasPage';
import UnidadesPage from './pages/UnidadesPage';

// Crear QueryClient
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

// Componente para rutas protegidas
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated } = useAuthStore();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return <>{children}</>;
}

// Componente para rutas de Operaciones (solo OPERACIONES y ADMIN)
function OperacionesRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, user } = useAuthStore();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (user?.rol !== 'OPERACIONES' && user?.rol !== 'ADMIN') {
    return <Navigate to="/dashboard" replace />;
  }

  return <>{children}</>;
}

// Componente de redirección inteligente según rol
function RoleBasedRedirect() {
  const { user, isAuthenticated } = useAuthStore();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  // Usuarios de Operaciones van a su módulo
  if (user?.rol === 'OPERACIONES') {
    return <Navigate to="/operaciones" replace />;
  }

  // Admin puede elegir, por defecto va al Dashboard COP
  if (user?.rol === 'ADMIN') {
    return <Navigate to="/dashboard" replace />;
  }

  // Todos los demás van al Dashboard COP
  return <Navigate to="/dashboard" replace />;
}

function App() {
  const { initializeAuth } = useAuthStore();

  // Inicializar autenticación desde localStorage
  useEffect(() => {
    initializeAuth();
  }, [initializeAuth]);

  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route
            path="/dashboard"
            element={
              <ProtectedRoute>
                <DashboardPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/operaciones"
            element={
              <OperacionesRoute>
                <OperacionesPage />
              </OperacionesRoute>
            }
          />
          <Route
            path="/operaciones/crear-asignacion"
            element={
              <OperacionesRoute>
                <CrearAsignacionPage />
              </OperacionesRoute>
            }
          />
          <Route
            path="/operaciones/generador"
            element={
              <OperacionesRoute>
                <GeneradorTurnosPage />
              </OperacionesRoute>
            }
          />
          <Route
            path="/operaciones/brigadas"
            element={
              <OperacionesRoute>
                <BrigadasPage />
              </OperacionesRoute>
            }
          />
          <Route
            path="/operaciones/unidades"
            element={
              <OperacionesRoute>
                <UnidadesPage />
              </OperacionesRoute>
            }
          />
          <Route path="/" element={<RoleBasedRedirect />} />
          <Route path="*" element={<RoleBasedRedirect />} />
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  );
}

export default App;
