import React, { Suspense, lazy } from 'react';
import { BrowserRouter, Routes, Route, Navigate, useLocation } from './shared/utils/router';
import { useAuth, getPortalForRole } from './shared/components/auth/AuthContext';
import PortalHome from './pages/PortalHome';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';

// Lazy-load portals — each is a separate chunk
const CEOPortal        = lazy(() => import('./portals/ceo'));
const ExecutivePortal  = lazy(() => import('./portals/executive'));
const CLevelPortal     = lazy(() => import('./portals/clevel'));
const OperationsPortal = lazy(() => import('./portals/operations'));
const TechnologyPortal = lazy(() => import('./portals/technology'));
const AgentsPortal     = lazy(() => import('./portals/agents'));

// Allowed roles per portal path
const PORTAL_ROLES: Record<string, string[]> = {
  '/gatewayalpha':  ['CEO'],
  '/gatewaydelta':  ['CFO', 'CoS', 'EA', 'CFO_ASSISTANT'],
  '/gatewaysigma':  ['COO', 'CTO'],
  '/gatewaynexus':  ['OPERATIONS_USER', 'HEAD_OF_TRAINERS', 'TRAINER'],
  '/gatewayvertex': ['TECH_STAFF', 'DEVELOPER'],
  '/gatewaypulse':  ['AGENT'],
};

const PORTAL_GATEWAYS: Record<string, string> = {
  ceo: '/gatewayalpha',
  executive: '/gatewaydelta',
  clevel: '/gatewaysigma',
  operations: '/gatewaynexus',
  technology: '/gatewayvertex',
  agents: '/gatewaypulse',
};

function resolveStandaloneGateway(): string | null {
  const envPortal = (import.meta.env.VITE_STANDALONE_PORTAL as string | undefined)?.trim().toLowerCase();
  if (envPortal && PORTAL_GATEWAYS[envPortal]) {
    return PORTAL_GATEWAYS[envPortal];
  }

  const host = window.location.hostname.toLowerCase();
  if (host.includes('erp-ceo-portal')) return '/gatewayalpha';
  if (host.includes('erp-executive-portal')) return '/gatewaydelta';
  if (host.includes('erp-clevel-portal')) return '/gatewaysigma';
  if (host.includes('erp-operations-portal')) return '/gatewaynexus';
  if (host.includes('erp-technology-portal')) return '/gatewayvertex';
  if (host.includes('erp-agents-portal')) return '/gatewaypulse';

  return null;
}

function shouldRedirectRootToLogin(): boolean {
  const host = window.location.hostname.toLowerCase();
  return host === 'core.techswifttrix.com';
}

function LoadingSpinner() {
  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-50">
      <div className="text-center">
        <div className="w-12 h-12 border-4 border-gray-200 border-t-indigo-600 rounded-full animate-spin mx-auto mb-4" />
        <p className="text-gray-500 text-sm font-medium">Loading portal…</p>
      </div>
    </div>
  );
}

/**
 * Guards a portal route:
 * - Not authenticated → redirect to /login (with return path)
 * - Wrong role → redirect to their correct portal
 * - Correct role → render children
 */
function PortalGuard({ portalPath, children }: { portalPath: string; children: React.ReactNode }) {
  const { isAuthenticated, isLoading, user } = useAuth();
  const location = useLocation();

  if (isLoading) return <LoadingSpinner />;

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // Check if user's role is allowed for this portal
  const allowedRoles = PORTAL_ROLES[portalPath] ?? [];
  const userRole = user?.role ?? '';

  if (!allowedRoles.includes(userRole)) {
    // Redirect to their correct portal
    const correctPortal = getPortalForRole(userRole);
    if (correctPortal !== portalPath) {
      return <Navigate to={correctPortal} replace />;
    }
  }

  return <>{children}</>;
}

function App() {
  const standaloneGateway = resolveStandaloneGateway();
  const redirectRootToLogin = shouldRedirectRootToLogin();

  return (
    <BrowserRouter>
      <Suspense fallback={<LoadingSpinner />}>
        <Routes>
          <Route
            path="/"
            element={
              redirectRootToLogin
                ? <Navigate to="/login" replace />
                : standaloneGateway
                  ? <Navigate to={standaloneGateway} replace />
                  : <PortalHome />
            }
          />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />

          <Route path="/gatewayalpha" element={
            <PortalGuard portalPath="/gatewayalpha"><CEOPortal /></PortalGuard>
          } />
          <Route path="/gatewaydelta" element={
            <PortalGuard portalPath="/gatewaydelta"><ExecutivePortal /></PortalGuard>
          } />
          <Route path="/gatewaysigma" element={
            <PortalGuard portalPath="/gatewaysigma"><CLevelPortal /></PortalGuard>
          } />
          <Route path="/gatewaynexus" element={
            <PortalGuard portalPath="/gatewaynexus"><OperationsPortal /></PortalGuard>
          } />
          <Route path="/gatewayvertex" element={
            <PortalGuard portalPath="/gatewayvertex"><TechnologyPortal /></PortalGuard>
          } />
          <Route path="/gatewaypulse" element={
            <PortalGuard portalPath="/gatewaypulse"><AgentsPortal /></PortalGuard>
          } />

          {/* Catch-all → home */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}

export default App;
